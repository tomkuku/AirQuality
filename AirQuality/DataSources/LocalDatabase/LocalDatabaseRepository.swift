//
//  LocalDatabaseRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

final class LocalDatabaseRepository {
    private let localDatabaseDataStore: LocalDatabaseDataStoreProtocol
    
    init(localDatabaseDataStore: LocalDatabaseDataStoreProtocol) {
        self.localDatabaseDataStore = localDatabaseDataStore
    }
    
    func insert<T>(mapper: T, object: T.DomainModel) throws where T: LocalDatabaseMapperProtocol {
        let databaseObject = try mapper.map(object)
        
        localDatabaseDataStore.insert(databaseObject)
    }
    
    func fetch<T>(_ fetchDescription: FetchDescriptor<T>) throws -> [T] where T: PersistentModel {
        try 
    }
}
