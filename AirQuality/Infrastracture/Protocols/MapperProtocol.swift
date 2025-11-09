//
//  Mappers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation
import protocol SwiftData.PersistentModel

protocol MapperProtocol: Sendable {
    associatedtype DTOModel
    associatedtype DomainModel: Sendable
    associatedtype InputParameters: Sendable
    
    init()
    
    func map(_ input: DTOModel, using inputParameters: InputParameters) throws -> DomainModel
}

extension MapperProtocol where InputParameters == Void {
    func map(_ input: DTOModel) throws -> DomainModel {
        try map(input, using: ())
    }
}

protocol NetworkMapperProtocol: MapperProtocol where DTOModel: Decodable {}

protocol LocalDatabaseMapperProtocol: MapperProtocol
where DTOModel: LocalDatabaseModel,
      DomainModel: Identifiable,
      DTOModel.IdentifierType == DomainModel.ID {
    func map(_ input: DomainModel) throws -> DTOModel
}
