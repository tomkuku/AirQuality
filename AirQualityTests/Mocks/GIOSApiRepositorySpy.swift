//
//  GIOSApiRepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

@testable import AirQuality

final class GIOSApiRepositorySpy: GIOSApiRepositoryProtocol, @unchecked Sendable {
    
    enum Event: Equatable {
        case fetch(String, URLRequest, String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.fetch(method1, request1, path1), .fetch(method2, request2, path2)):
                method1 == method2 && request1 == request2 && path1 == path2
            }
        }
    }
    
    private(set) var events: [Event] = []
    
    var fetchResult: Result<Any, Error>!
    
    func fetch<T, R>(
        mapperType: T.Type,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: MapperProtocol, R: HTTPRequest {
        events.append(.fetch(String(describing: T.DomainModel.self), try! endpoint.asURLRequest(), contentContainerName)) // swiftlint:disable:this force_try
        
        return try await withCheckedThrowingContinuation { continuation in
            switch fetchResult {
            case .success(let domainModel):
                continuation.resume(returning: domainModel as! T.DomainModel) // swiftlint:disable:this force_cast
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                break
            }
        }
    }
}
