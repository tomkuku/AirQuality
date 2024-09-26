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
    
    override func setUp() {
        super.setUp()
        
        pathMonitorSpy = PathMonitorSpy()
        sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorSpy)
    }
    
    func testWhenNetworkStatusIsSatisfied() {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let path = createNWPath(with: .satisfied)
        
        sut.startMonitor {
            XCTFail("Network connection should be available!")
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenNetworkStatusIsUnsatisfied() {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let path = createNWPath(with: .unsatisfied)
        
        sut.startMonitor {
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testWhenNetworkStatusIsRequiresConnection() {
        // Given
        let pathMonitorMock = PathMonitorSpy()
        
        let sut = NetworkConnectionMonitorUseCase(pathMonitor: pathMonitorMock)
        
        let path = createNWPath(with: .requiresConnection)
        
        sut.startMonitor {
            self.expectation.fulfill()
        }
        
        // When
        pathMonitorMock.pathUpdateHandler?(path)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(pathMonitorMock.events, [.start])
    }
    
    func testCancel() {
        // When
        sut = nil
        
        // Then
        XCTAssertEqual(pathMonitorSpy.events, [.cancel])
    }
    
    // MARK: Private methods
    
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
