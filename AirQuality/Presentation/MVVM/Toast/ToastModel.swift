//
//  ToastModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation

struct ToastModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let body: String
    
    init(body: String) {
        self.id = UUID()
        self.body = body
    }
}

extension ToastModel {
    static func observedStationWasDeleted() -> Self {
        Self(body: Localizable.ToastModel.observedStationWasDeleted)
    }
    
    static func observedStationWasAdded() -> Self {
        Self(body: Localizable.ToastModel.observedStationWasAdded)
    }
    
    static func noInternetConnection() -> Self {
        Self(body: Localizable.ToastModel.noInternetConnection)
    }
}
