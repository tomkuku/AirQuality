//
//  LocalDatabaseMapperProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import protocol SwiftData.PersistentModel

protocol LocalDatabaseMapperProtocol: MapperProtocol
where DTOModel: LocalDatabaseModel,
      DomainModel: Identifiable,
      DTOModel.IdentifierType == DomainModel.ID {
    func map(_ input: DomainModel) throws -> DTOModel
}
