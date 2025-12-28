//
//  SimulatedNetworkFilter.swift
//  DiskDevil
//
//  Simulated network filter for development and testing
//  This will be replaced by NetworkExtensionFilter when the real extension is implemented

import Foundation
import Combine

// MARK: - SimulatedNetworkFilter

class SimulatedNetworkFilter: NetworkFilterProtocol {
    // MARK: Internal
    
    private(set) var isEnabled = false
    
    var statusPublisher: AnyPublisher<NetworkFilterStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    func start(with rules: [NetworkFilterRule]) async -> Result<Void, NetworkFilterError> {
        guard !isEnabled else {
            return .success(())
        }
        
        statusSubject.send(.starting)
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        currentRules = rules
        isEnabled = true
        startTime = Date()
        
        // Start simulated monitoring
        startSimulation()
        
        statusSubject.send(.active)
        return .success(())
    }
    
    func stop() async -> Result<Void, NetworkFilterError> {
        guard isEnabled else {
            return .success(())
        }
        
        statusSubject.send(.stopping)
        
        stopSimulation()
        
        isEnabled = false
        currentRules = []
        startTime = nil
        
        statusSubject.send(.idle)
        return .success(())
    }
    
    func updateRules(_ rules: [NetworkFilterRule]) async -> Result<Void, NetworkFilterError> {
        currentRules = rules
        return .success(())
    }
    
    func getStatistics() async -> NetworkFilterStatistics {
        NetworkFilterStatistics(
            totalBlocked: blockedCount,
            blockedByCategory: blockedByCategory,
            topBlockedDomains: topBlockedDomains,
            activeRules: currentRules.count,
            startTime: startTime
        )
    }
    
    // MARK: Private
    
    private let statusSubject = CurrentValueSubject<NetworkFilterStatus, Never>(.idle)
    private var currentRules: [NetworkFilterRule] = []
    private var startTime: Date?
    private var simulationTimer: Timer?
    
    private var blockedCount = 0
    private var blockedByCategory: [String: Int] = [:]
    private var topBlockedDomains: [(String, Int)] = []
    
    private func startSimulation() {
        // Simulate blocking connections periodically
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.simulateBlocking()
        }
    }
    
    private func stopSimulation() {
        simulationTimer?.invalidate()
        simulationTimer = nil
        blockedCount = 0
        blockedByCategory = [:]
        topBlockedDomains = []
    }
    
    private func simulateBlocking() {
        // Randomly simulate blocking based on current rules
        guard !currentRules.isEmpty else { return }
        
        if Int.random(in: 0...10) > 6 {
            let rule = currentRules.randomElement()!
            blockedCount += 1
            
            // Update category statistics
            let category = extractCategory(from: rule)
            blockedByCategory[category, default: 0] += 1
            
            // Update domain statistics
            updateTopBlockedDomains(from: rule)
        }
    }
    
    private func extractCategory(from rule: NetworkFilterRule) -> String {
        switch rule.condition.type {
        case .category:
            return rule.condition.pattern
        case .domain, .domainSuffix:
            return "tracking"
        default:
            return "other"
        }
    }
    
    private func updateTopBlockedDomains(from rule: NetworkFilterRule) {
        let domain = rule.condition.pattern
        
        if let index = topBlockedDomains.firstIndex(where: { $0.0 == domain }) {
            topBlockedDomains[index].1 += 1
        } else {
            topBlockedDomains.append((domain, 1))
        }
        
        // Keep only top 10
        topBlockedDomains.sort { $0.1 > $1.1 }
        if topBlockedDomains.count > 10 {
            topBlockedDomains = Array(topBlockedDomains.prefix(10))
        }
    }
}
