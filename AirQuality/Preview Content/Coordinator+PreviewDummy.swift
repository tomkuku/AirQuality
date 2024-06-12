//
//  Coordinator+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation

extension CoordinatorBase {
    nonisolated(unsafe) static let previewDummy = CoordinatorBase(coordinatorNavigationType: .presentation(dismissHandler: {}))
}
