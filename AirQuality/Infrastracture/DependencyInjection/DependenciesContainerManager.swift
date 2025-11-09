//
//  DependenciesContainerManager.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

final class DependenciesContainerManager: Sendable {
    // It's similar to a pointer because by using `unowned` it doesn't have strong reference to the container.
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    nonisolated(unsafe) static unowned var container: DependenciesContainerProtocol!
}
