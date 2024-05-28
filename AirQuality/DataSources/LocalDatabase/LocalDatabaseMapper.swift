//
//  LocalDatabaseMapperProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol LocalDatabaseMapperProtocol: MapperProtocol where DTOModel: PersistentModel { 
    func map(_ input: DomainModel) throws -> DTOModel
}
