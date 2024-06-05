//
//  LocalDatabaseMapperSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation

@testable import AirQuality

final class LocalDatabaseMapperSpy: LocalDatabaseMapperProtocol, @unchecked Sendable {
    typealias DomainModel = DomainModelDummy
    typealias DTOModel = LocalDatabaseModelDummy
    
    var mapToDatabaseModelReturnValueClosure: ((DomainModelDummy) -> (LocalDatabaseModelDummy))!
    var mapToDomainModelReturnValueClosure: ((LocalDatabaseModelDummy) -> (DomainModelDummy))!
    
    required init() { }
    
    func map(_ input: LocalDatabaseModelDummy) throws -> DomainModelDummy {
        mapToDomainModelReturnValueClosure(input)
    }
    
    func map(_ input: DomainModelDummy) throws -> LocalDatabaseModelDummy {
        mapToDatabaseModelReturnValueClosure(input)
    }
}
