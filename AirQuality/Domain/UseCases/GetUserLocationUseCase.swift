//
//  GetUserLocationUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/06/2024.
//

import Foundation

protocol HasGetUserLocationUseCase {
    var getUserLocationUseCase: GetUserLocationUseCaseProtocol { get }
}

protocol GetUserLocationUseCaseProtocol: Sendable {
    func checkLocationServicesAvailability() async throws
    
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error>
}

actor GetUserLocationUseCase: GetUserLocationUseCaseProtocol {
    @Injected(\.locationRespository) private var locationRespository
    
    func checkLocationServicesAvailability() async throws {
        try await locationRespository.checkLocationServicesAvailability()
    }
    
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error> {
        await locationRespository.streamLocation(finishClosure: &finishClosure)
    }
}
