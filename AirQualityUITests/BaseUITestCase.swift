//
//  BaseUITestCase.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 08/11/2025.
//

import Foundation
import XCTest
import SnapshotTesting

@testable import AirQuality

final class EnvironmentConstant: EnvironmentConstantsProtocol {
    var baseUrl: String {
        "http://test.com"
    }
}

final class DependenciesContainerDummy: DependenciesContainerProtocol {
    subscript<T>(_ keyPath: KeyPath<AllDependencies, T>) -> T {
        get {
            guard let dependnecy = self.container[keyPath] as? T else {
                fatalError("Dependency \(String(describing: T.self)) not found!")
            }
            return dependnecy
        } set {
            container[keyPath] = newValue
        }
    }
    
    private var container: [PartialKeyPath<AllDependencies>: Any] = [:]
}

@MainActor
class BaseUITestCase: XCTestCase, @unchecked Sendable { // swiftlint:disable:this final_test_case
    
    var dependenciesContainerDummy: DependenciesContainerDummy!
    var appDependencies: DependenciesContainerProtocol!
    
    override func setUp() async throws {
        try await super.setUp()
        
        appDependencies = DependenciesContainerManager.container
        
        dependenciesContainerDummy = DependenciesContainerDummy()
        
        DependenciesContainerManager.container = dependenciesContainerDummy
        
        dependenciesContainerDummy[\.environmentConstants] = EnvironmentConstant()
    }
    
    override func record(_ issue: XCTIssue) {
        super.record(issue)
        
        DispatchQueue.main.async {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            
            attachment.lifetime = .keepAlways
            attachment.name = "Failure Screenshot"
            
            self.add(attachment)
        }
    }
}

extension BaseUITestCase {
    func testSnapshot(imageName: String, file: StaticString = #filePath) {
        let screenshot = XCUIScreen.main.screenshot()
        let snapshot = UIImage(data: screenshot.pngRepresentation)!
        
        assertSnapshot(
            of: snapshot,
            as: .image(precision: 0.95),
            named: "test",
            record: false,
            file: file,
            testName: imageName
        )
    }
    
    func tapCell(in collectionView: XCUIElement, index cellIndex: Int) {
        let firstCell = collectionView.cells.element(boundBy: cellIndex)
        
        XCTAssertTrue(firstCell.exists)
        
        firstCell.tap()
    }
    
    func tapAtSpecificPoint(_ point: CGPoint, onApp app: XCUIApplication) {
        let point = CGVector(dx: point.x, dy: point.y)
        let coordinate = app.coordinate(withNormalizedOffset: .zero)
        let targetCoordinate = coordinate.withOffset(point)
        
        targetCoordinate.tap()
    }
}
