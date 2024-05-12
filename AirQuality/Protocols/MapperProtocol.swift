//
//  Mappers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

protocol MapperProtocol {
    associatedtype NetworkModel: Decodable
    associatedtype DomainModel
    
    init()
    
    func map(_ input: NetworkModel) throws -> DomainModel
}
