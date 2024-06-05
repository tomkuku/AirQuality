//
//  ModelContainerSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import SwiftData

final class ModelContainerSpy {
    let modelContainer: ModelContainer
    
    var modelContext: ModelContext {
        ModelContext(modelContainer)
    }
    
    init(schemeModels: [any PersistentModel.Type]) {
        let schema = Schema([LocalDatabaseModelDummy.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Creating model container failed with error: \(error.localizedDescription)")
        }
    }
}
