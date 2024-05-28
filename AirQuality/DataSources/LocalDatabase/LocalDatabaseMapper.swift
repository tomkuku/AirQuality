//
//  LocalDatabaseMapperProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import protocol SwiftData.PersistentModel

protocol LocalDatabaseMapperProtocol: MapperProtocol where DTOModel: PersistentModel & Sendable {
    func mapDomainModel(_ input: DomainModel) throws -> DTOModel
}
