//
//  GIOSApiV1RepositoryMocks.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 19/06/2024.
//

import Foundation

@testable import AirQuality

extension GIOSApiV1RepositoryTests {
    
    // MARK: - Helper Types
    
    struct DomainModelFake: Sendable, Equatable {
        let name: String
    }
    
    struct DTOModelFake: Decodable, Equatable {
        let name: String
    }
    
    struct InputParametersFake: Sendable, Equatable {
        let value: String
    }
    
    // MARK: - NetworkMapperFake (Void input parameters)
    
    final class NetworkMapperFake: NetworkMapperProtocol, @unchecked Sendable {
        typealias DTOModel = [DTOModelFake]
        typealias DomainModel = [DomainModelFake]
        typealias InputParameters = Void
        
        var mapCallCount = 0
        var lastInput: [DTOModelFake]?
        var mapResult: Result<[DomainModelFake], Error> = .failure(ErrorDummy())
        
        required init() { }
        
        func map(_ input: [DTOModelFake], using inputParameters: Void) throws -> [DomainModelFake] {
            mapCallCount += 1
            lastInput = input
            
            switch mapResult {
            case .success(let model):
                return model
            case .failure(let error):
                throw error
            }
        }
    }
    
    // MARK: - NetworkMapperWithInputFake (with input parameters)
    
    final class NetworkMapperWithInputFake: NetworkMapperProtocol, @unchecked Sendable {
        typealias DTOModel = [DTOModelFake]
        typealias DomainModel = [DomainModelFake]
        typealias InputParameters = InputParametersFake
        
        var mapCallCount = 0
        var lastInput: [DTOModelFake]?
        var lastInputParameters: InputParametersFake?
        var mapResult: Result<[DomainModelFake], Error> = .failure(ErrorDummy())
        
        required init() { }
        
        func map(_ input: [DTOModelFake], using inputParameters: InputParametersFake) throws -> [DomainModelFake] {
            mapCallCount += 1
            lastInput = input
            lastInputParameters = inputParameters
            
            switch mapResult {
            case .success(let model):
                return model
            case .failure(let error):
                throw error
            }
        }
    }
}
