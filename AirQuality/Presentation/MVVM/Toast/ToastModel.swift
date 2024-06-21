//
//  ToastModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation

struct Toast: Identifiable, Equatable, Hashable {
    let id: UUID
    let body: String
    
    init(body: String) {
        self.id = UUID()
        self.body = body
    }
}

extension Toast {
    static func observedStationWasDeleted() -> Self {
        .init(body: Localizable.Toast.observedStationWasDeleted)
    }
}
