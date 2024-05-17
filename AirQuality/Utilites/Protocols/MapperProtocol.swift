//
//  Mappers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

protocol MapperProtocol {
    associatedtype DTOModel
    associatedtype DomainModel
    
    init()
    
    func map(_ input: DTOModel) throws -> DomainModel
}

protocol NetworkMapperProtocol: MapperProtocol where DTOModel: Decodable { }
