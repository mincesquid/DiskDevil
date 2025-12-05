//
//  HiddenFilesView.swift
//  Mad Scientist
//

import SwiftUI

struct HiddenFilesView: View {
    @State private var showHiddenFiles = false
    @State private var currentPath = FileManager.default.homeDirectoryForCurrentUser.path
    @State private var files: [FileItem] = []

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "eye.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("Hidden Files Browser")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Reveal and manage hidden files on your system")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // Toggle
            HStack {
                Text("Show Hidden Files")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $showHiddenFiles)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            // Path
            HStack {
                Text("Current Path:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(currentPath)
                    .font(.system(.subheadline, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)

            // File List
            List(files) { file in
                HStack {
                    Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundColor(file.isDirectory ? .blue : .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.name)
                            .font(.body)
                            .foregroundColor(file.isHidden ? .secondary : .primary)
                        Text(file.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if file.isHidden {
                        Text("Hidden")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.inset)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .onAppear {
            loadFiles()
        }
        .onChange(of: showHiddenFiles, perform: { _ in
            loadFiles()
        })
    }

    private func loadFiles() {
        let url = URL(fileURLWithPath: currentPath)
        var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants]

        if !showHiddenFiles {
            options.insert(.skipsHiddenFiles)
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .isHiddenKey],
                options: options
            )

            files = contents.compactMap { url in
                let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isHiddenKey])
                return FileItem(
                    name: url.lastPathComponent,
                    path: url.path,
                    isDirectory: resourceValues?.isDirectory ?? false,
                    isHidden: resourceValues?.isHidden ?? false
                )
            }.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            files = []
        }
    }
}

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let isHidden: Bool
}
