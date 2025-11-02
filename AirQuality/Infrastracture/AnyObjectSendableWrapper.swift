//
//  AnyObjectSendableWrapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 20/05/2025.
//

import Foundation

final class AnyObjectSendableWrapper<T>: @unchecked Sendable where T: AnyObject {
    unowned var object: T
    
    init(_ object: T) {
        self.object = object
    }
}
