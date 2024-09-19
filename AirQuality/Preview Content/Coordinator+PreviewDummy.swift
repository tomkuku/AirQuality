//
//  Coordinator+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import Combine

extension CoordinatorBase {
    nonisolated(unsafe) static let previewDummy = CoordinatorBase(
        coordinatorNavigationType: .presentation(dismissHandler: {}),
        alertSubject: PassthroughSubject<AlertModel, Never>()
    )
    
//    convenience init() {
//        let alertSubject =
//        self.init(coordinatorNavigationType: .presentation(dismissHandler: {}), alertSubject: alertSubject)
//    }
}
