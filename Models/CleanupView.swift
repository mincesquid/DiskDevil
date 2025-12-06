//
//  CleanupView.swift
//  DiskDevil
//

import AppKit
import SwiftUI

struct CleanupView: View {
    @State private var categories: [CleanupCategoryState] = CleanupCategoryKind.allCases.map { CleanupCategoryState(kind: $0) }
    @State private var selectedItems: Set<UUID> = []
    @State private var isScanning = false
    @State private var isCleaning = false
    @State private var userMessage: String?
    @State private var alert: CleanupAlert?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                Text("Smart Cleanup")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Audit caches, logs, downloads, tmp, and trash")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                        .glassCard()
                    actionButtons

                    ForEach(categories) { category in
                        CleanupCategoryCard(
                            category: category,
                            isScanning: isScanning,
                            selectedItems: selectedItems,
                            onToggle: { toggleSelection(for: $0) },
                            onReveal: { reveal($0.url) },
                            onSelectAll: { selectAll(in: category) },
                            onSelectNone: { deselectAll(in: category) }
                        )
                    }

                    if let userMessage {
                        Text(userMessage)
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .background(Color.clear)
        .aeroBackground()
        .onAppear {
            scanAllCategories()
        }
        .alert(item: $alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Detected")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(formatBytes(totalDiscoveredBytes))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AeroTheme.accent)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Selected")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(formatBytes(selectedBytes))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Items")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(selectedItems.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: scanAllCategories) {
                Label(isScanning ? "Scanning..." : "Scan", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isScanning || isCleaning)

            Button(action: performCleanup) {
                Label(isCleaning ? "Cleaning..." : "Clean Selected", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isScanning || selectedItems.isEmpty || isCleaning)
        }
    }

    private var totalDiscoveredBytes: Int64 {
        categories.reduce(0) { partial, category in
            partial + category.totalBytes
        }
    }

    private var selectedBytes: Int64 {
        categories.reduce(0) { partial, category in
            partial + category.files
                .filter { selectedItems.contains($0.id) }
                .reduce(0) { $0 + $1.size }
        }
    }

    private func scanAllCategories() {
        isScanning = true
        userMessage = "Scanning file system…"
        selectedItems.removeAll()
        categories = CleanupCategoryKind.allCases.map { CleanupCategoryState(kind: $0) }

        for kind in CleanupCategoryKind.allCases {
            updateCategory(kind) { state in
                state.status = .scanning
                state.message = "Scanning \(kind.title)…"
                state.files = []
                state.totalBytes = 0
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let scanned = performScan(for: kind)
                DispatchQueue.main.async {
                    apply(scanResult: scanned)
                }
            }
        }
    }

    private func performScan(for kind: CleanupCategoryKind) -> CleanupCategoryState {
        var state = CleanupCategoryState(kind: kind)
        let fm = FileManager.default
        var errors: [String] = []

        for location in kind.locations {
            let resolved = location.expandingTilde
            guard fm.fileExists(atPath: resolved.path) else {
                continue
            }

            do {
                let entries = try collectEntries(at: resolved, limit: location.limit)
                state.files.append(contentsOf: entries)
                state.totalBytes += entries.reduce(0) { $0 + $1.size }
            } catch {
                errors.append("\(resolved.path): \(error.localizedDescription)")
            }
        }

        state.files.sort { $0.size > $1.size }
        if state.files.count > 60 {
            state.files = Array(state.files.prefix(60))
        }

        state.status = errors.isEmpty ? .completed : .error
        state.message = errors.isEmpty ? "Scan finished" : errors.joined(separator: "\n")
        state.lastScan = Date()

        return state
    }

    private func collectEntries(at url: URL, limit: Int) throws -> [CleanupFile] {
        let fm = FileManager.default
        var entries: [CleanupFile] = []
        let resources: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .totalFileAllocatedSizeKey, .contentModificationDateKey]

        if let contents = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: Array(resources), options: [.skipsPackageDescendants]) {
            for child in contents {
                let size = sizeOfItem(at: child)
                guard size > 0 else { continue }
                let resourceValues = try? child.resourceValues(forKeys: resources)
                let date = resourceValues?.contentModificationDate

                entries.append(CleanupFile(
                    url: child,
                    size: size,
                    lastModified: date
                ))

                if entries.count >= limit {
                    break
                }
            }
        } else {
            let size = sizeOfItem(at: url)
            guard size > 0 else { return [] }
            let resourceValues = try? url.resourceValues(forKeys: resources)
            entries.append(CleanupFile(
                url: url,
                size: size,
                lastModified: resourceValues?.contentModificationDate
            ))
        }

        return entries
    }

    private func sizeOfItem(at url: URL) -> Int64 {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false

        guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return 0
        }

        if !isDirectory.boolValue {
            if let attrs = try? fm.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? NSNumber
            {
                return size.int64Value
            }
            return 0
        }

        var total: Int64 = 0
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey, .totalFileAllocatedSizeKey]

        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles], errorHandler: nil) {
            for case let fileURL as URL in enumerator {
                guard let values = try? fileURL.resourceValues(forKeys: resourceKeys) else { continue }
                if values.isDirectory == true {
                    continue
                }

                if let allocated = values.totalFileAllocatedSize {
                    total += Int64(allocated)
                } else if let fileSize = values.fileSize {
                    total += Int64(fileSize)
                }
            }
        }

        return total
    }

    private func apply(scanResult: CleanupCategoryState) {
        updateCategory(scanResult.kind) { state in
            state.files = scanResult.files
            state.totalBytes = scanResult.totalBytes
            state.status = scanResult.status
            state.message = scanResult.message
            state.lastScan = scanResult.lastScan
        }

        if scanResult.status == .error {
            userMessage = scanResult.message
        }

        for file in scanResult.files {
            selectedItems.insert(file.id)
        }

        if categories.allSatisfy({ $0.status == .completed || $0.status == .error }) {
            isScanning = false
            userMessage = "Scan completed. Review and clean selected locations."
        }
    }

    private func performCleanup() {
        let targets = categories.flatMap { category in
            category.files.filter { selectedItems.contains($0.id) }
        }

        guard !targets.isEmpty else {
            alert = CleanupAlert(title: "Nothing Selected", message: "Select items before attempting cleanup.")
            return
        }

        isCleaning = true
        userMessage = "Removing selected files…"

        DispatchQueue.global(qos: .userInitiated).async {
            var errors: [String] = []
            for file in targets {
                do {
                    try Self.deleteItem(at: file.url)
                } catch {
                    errors.append("\(file.url.lastPathComponent): \(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {
                isCleaning = false
                if errors.isEmpty {
                    alert = CleanupAlert(title: "Cleanup Complete", message: "Removed \(targets.count) item(s).")
                } else {
                    alert = CleanupAlert(title: "Cleanup Finished with Warnings", message: errors.joined(separator: "\n"))
                }
                scanAllCategories()
            }
        }
    }

    private func toggleSelection(for file: CleanupFile) {
        if selectedItems.contains(file.id) {
            selectedItems.remove(file.id)
        } else {
            selectedItems.insert(file.id)
        }
    }

    private func selectAll(in category: CleanupCategoryState) {
        for file in category.files {
            selectedItems.insert(file.id)
        }
    }

    private func deselectAll(in category: CleanupCategoryState) {
        for file in category.files {
            selectedItems.remove(file.id)
        }
    }

    private func reveal(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func updateCategory(_ kind: CleanupCategoryKind, apply changes: (inout CleanupCategoryState) -> Void) {
        if let index = categories.firstIndex(where: { $0.kind == kind }) {
            var updated = categories[index]
            changes(&updated)
            categories[index] = updated
        } else {
            var state = CleanupCategoryState(kind: kind)
            changes(&state)
            categories.append(state)
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private static func deleteItem(at url: URL) throws {
        let fm = FileManager.default
        do {
            try fm.trashItem(at: url, resultingItemURL: nil)
        } catch {
            try fm.removeItem(at: url)
        }
    }
}

private struct CleanupCategoryCard: View {
    let category: CleanupCategoryState
    let isScanning: Bool
    let selectedItems: Set<UUID>
    let onToggle: (CleanupFile) -> Void
    let onReveal: (CleanupFile) -> Void
    let onSelectAll: () -> Void
    let onSelectNone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.kind.icon)
                    .foregroundColor(category.kind.color)
                VStack(alignment: .leading) {
                    Text(category.kind.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(category.kind.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }

            HStack {
                Text(ByteCountFormatter.string(fromByteCount: category.totalBytes, countStyle: .file))
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("Select All", action: onSelectAll)
                    .disabled(category.files.isEmpty)
                Button("Select None", action: onSelectNone)
                    .disabled(category.files.isEmpty)
            }

            if category.status == .scanning {
                ProgressView("Scanning \(category.kind.title)…")
                    .progressViewStyle(.linear)
            } else if category.files.isEmpty {
                Text("Nothing found in \(category.kind.title).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(category.files) { file in
                        CleanupFileRow(
                            file: file,
                            isSelected: selectedItems.contains(file.id),
                            onToggle: { onToggle(file) },
                            onReveal: { onReveal(file) }
                        )
                    }
                }
            }

            if let message = category.message, category.status == .error {
                Text(message)
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .glassCard()
    }

    private var statusText: String {
        switch category.status {
        case .pending: return "Pending"
        case .scanning: return "Scanning"
        case .completed: return "Ready"
        case .error: return "Warning"
        }
    }

    private var statusColor: Color {
        switch category.status {
        case .pending: return .gray
        case .scanning: return .blue
        case .completed: return .green
        case .error: return .red
        }
    }
}

private struct CleanupFileRow: View {
    let file: CleanupFile
    let isSelected: Bool
    let onToggle: () -> Void
    let onReveal: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(file.url.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let lastModified = file.lastModified {
                    Text("Modified \(lastModified, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
                    .font(.caption)
                    .fontWeight(.semibold)
                Button("Reveal", action: onReveal)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .contentShape(Rectangle())
    }
}

private struct CleanupAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct CleanupCategoryState: Identifiable {
    let id = UUID()
    let kind: CleanupCategoryKind
    var files: [CleanupFile] = []
    var totalBytes: Int64 = 0
    var status: CleanupStatus = .pending
    var message: String?
    var lastScan: Date?
}

private struct CleanupFile: Identifiable {
    let id = UUID()
    let url: URL
    let size: Int64
    let lastModified: Date?

    var displayName: String {
        url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent
    }
}

private enum CleanupStatus {
    case pending
    case scanning
    case completed
    case error
}

private enum CleanupCategoryKind: String, CaseIterable {
    case caches
    case logs
    case downloads
    case temporary
    case trash

    var title: String {
        switch self {
        case .caches: return "Caches"
        case .logs: return "Logs"
        case .downloads: return "Downloads"
        case .temporary: return "Temporary Files"
        case .trash: return "Trash"
        }
    }

    var description: String {
        switch self {
        case .caches:
            return "Application caches, derived data, and Safari leftovers"
        case .logs:
            return "System/Application logs and diagnostics"
        case .downloads:
            return "Large, stale files inside Downloads"
        case .temporary:
            return "tmp contents and Xcode derived data"
        case .trash:
            return "Files still in your Trash"
        }
    }

    var icon: String {
        switch self {
        case .caches: return "folder.fill"
        case .logs: return "doc.text.fill"
        case .downloads: return "arrow.down.circle.fill"
        case .temporary: return "clock.arrow.circlepath"
        case .trash: return "trash.fill"
        }
    }

    var color: Color {
        switch self {
        case .caches: return .blue
        case .logs: return .orange
        case .downloads: return .green
        case .temporary: return .purple
        case .trash: return .red
        }
    }

    var locations: [CleanupLocation] {
        switch self {
        case .caches:
            return [
                CleanupLocation(path: "~/Library/Caches", limit: 40),
                CleanupLocation(path: "/Library/Caches", limit: 20),
                CleanupLocation(path: "~/Library/Developer/Xcode/DerivedData", limit: 20),
            ]
        case .logs:
            return [
                CleanupLocation(path: "~/Library/Logs", limit: 40),
                CleanupLocation(path: "/Library/Logs", limit: 20),
                CleanupLocation(path: "~/Library/DiagnosticReports", limit: 20),
            ]
        case .downloads:
            return [
                CleanupLocation(path: "~/Downloads", limit: 40),
            ]
        case .temporary:
            return [
                CleanupLocation(path: NSTemporaryDirectory(), limit: 40),
                CleanupLocation(path: "/tmp", limit: 20),
            ]
        case .trash:
            return [
                CleanupLocation(path: "~/.Trash", limit: 60),
            ]
        }
    }
}

private struct CleanupLocation {
    let path: String
    let limit: Int

    var expandingTilde: URL {
        if path.hasPrefix("~") {
            let expanded = (path as NSString).expandingTildeInPath
            return URL(fileURLWithPath: expanded)
        }
        return URL(fileURLWithPath: path)
    }
}
