//
//  Mappers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

protocol MapperProtocol: Sendable {
    associatedtype DTOModel
    associatedtype DomainModel: Sendable
    
    init()
    
    func map(_ input: DTOModel) throws -> DomainModel
}

protocol NetworkMapperProtocol: MapperProtocol where DTOModel: Decodable { }
