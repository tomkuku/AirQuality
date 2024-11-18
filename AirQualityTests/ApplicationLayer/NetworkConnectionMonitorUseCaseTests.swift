//
//  NetworkConnectionMonitorUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 26/09/2024.
//

import XCTest
import Network

@testable import AirQuality

final class NetworkConnectionMonitorUseCaseTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: NetworkConnectionMonitorUseCase!
    private var pathMonitorSpy: PathMonitorSpy!
    private var numberOfCalls: Int!
    
    override func setUp() {
        super.setUp()
        
        pathMonitorSpy = PathMonitorSpy()
        sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorSpy)
        
        numberOfCalls = 0
    }
    
    // MARK: isConnectionSatisfied
    
    func testIsConnectionSatisfiedWhenPathStatusIsSatisfied() async {
        // Given
        let path = createNWPath(with: .satisfied)
        pathMonitorSpy.currentPathReturnValue = path
        
        // When
        let result = await sut.isConnectionSatisfied
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testIsConnectionSatisfiedWhenPathStatusIsUnsatisfied() async {
        // Given
        let path = createNWPath(with: .unsatisfied)
        pathMonitorSpy.currentPathReturnValue = path
        
        // When
        let result = await sut.isConnectionSatisfied
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: Monitor status changes
    
    func testWhenNetworkStatusIsSatisfied() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let path = createNWPath(with: .satisfied)
        
        await sut.startMonitor {
            XCTFail("Network connection should be available!")
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        _ = await XCTWaiter().fulfillment(of: [.init()], timeout: 0.2)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenNetworkStatusIsUnsatisfied() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        let path = createNWPath(with: .unsatisfied)
        
        await sut.startMonitor {
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenNetworkStatusIsRequiresConnection() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        let path = createNWPath(with: .requiresConnection)
        
        await sut.startMonitor {
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenStatusChangesFromUnsatisfiedToRequiresConnection() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let unsatisfiedStatusPath = createNWPath(with: .unsatisfied)
        let requiresConnectionStatusPath = createNWPath(with: .requiresConnection)
        
        await sut.startMonitor {
            if self.numberOfCalls >= 1 {
                XCTFail("Call should be only once!")
            }
            
            self.numberOfCalls += 1
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(requiresConnectionStatusPath)
        _ = await XCTWaiter().fulfillment(of: [.init()], timeout: 0.2)
        pathMonitorMock.pathUpdateHandler?(unsatisfiedStatusPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenStatusChangesFromSatisfiedToSatisfied() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let path = createNWPath(with: .satisfied)
        
        await sut.startMonitor {
            XCTFail("Closure should not be called at all!")
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        _ = await XCTWaiter().fulfillment(of: [.init()], timeout: 0.2)
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenStatusChangesFromUnsatisfiedToSatisfied() async {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let unsatisfiedStatusPath = createNWPath(with: .unsatisfied)
        let satisfiedStatusPath = createNWPath(with: .satisfied)
        
        await sut.startMonitor {
            if self.numberOfCalls >= 1 {
                XCTFail("Call should be only once!")
            }
            
            self.numberOfCalls += 1
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(unsatisfiedStatusPath)
        _ = await XCTWaiter().fulfillment(of: [.init()], timeout: 0.2)
        pathMonitorMock.pathUpdateHandler?(satisfiedStatusPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    // MARK: Cancel
    
    func testCancel() {
        // When
        sut = nil
        
        // Then
        XCTAssertEqual(pathMonitorSpy.events, [.cancel])
    }
    
    // MARK: Private methods
    
    /// Any constructor of `NWPath` is not available publicly, therefore there is necessary to get `NWPath` using `currentPath`.
    /// Because of `status` of `NWPath` is constant, the value must be changed using `UnsafeMutablePointer`.
    private func createNWPath(with status: NWPath.Status) -> NWPath {
        let nwPathMonitor = NWPathMonitor()
        
        var path = nwPathMonitor.currentPath
        
        withUnsafeMutablePointer(to: &path) {
            guard let keyPathPointer = $0.pointer(to: \.status) else {
                XCTFail("Cannot use KeyPath<\(NWPath.self), \(NWPath.Status.self)> which is a computed KeyPath")
                return
            }
            
            let pointer = UnsafeMutablePointer(mutating: keyPathPointer)
            
            pointer.pointee = status
        }
        
        return path
    }
}
