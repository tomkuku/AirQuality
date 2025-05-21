//
//  SwiftDataPreviewAccessor.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 20/06/2024.
//

import Foundation
import SwiftData

protocol HasSwiftDataPreviewAccessor {
    var swiftDataPreviewAccessor: SwiftDataPreviewAccessor { get }
}

@MainActor
final class SwiftDataPreviewAccessor {
    // swiftlint:disable:next implicitly_unwrapped_optional
    nonisolated(unsafe) static var shared: SwiftDataPreviewAccessor!
    
    private let mainContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.mainContext = modelContainer.mainContext
    }
    
    func add(models: [any PersistentModel]) {
        models.forEach {
            mainContext.insert($0)
        }
        
        do {
            try mainContext.save()
        } catch {
            Logger.error("Saving models failed with error: \(error)")
        }
    }
}
