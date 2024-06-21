//
//  ParamsRepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class ParamsRepositorySpy: ParamsRepositoryProtocol, @unchecked Sendable {
    enum Event: Equatable, Hashable {
        case getParam(Int)
    }
    
    var events: [Event] = []
    
    var getParamReturnValueClosure: ((Int) -> (Param?))?
    
    func getParam(withId id: Int) -> Param? {
        events.append(.getParam(id))
        
        return getParamReturnValueClosure?(id)
    }
}
