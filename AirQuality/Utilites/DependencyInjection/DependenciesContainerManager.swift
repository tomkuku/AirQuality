//
//  DependenciesContainerManager.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

enum DependenciesContainerManager: Sendable {
    // https://github.com/apple/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md
    nonisolated(unsafe) static var container: DependenciesContainerProtocol!
}
