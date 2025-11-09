//
//  AlertModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI

struct AlertModel: Equatable, Sendable {
    struct Button: Equatable, Sendable {
        let title: String
        let role: ButtonRole?
        let action: (@Sendable () -> ())?
        
        init(title: String, role: ButtonRole? = nil, action: (@Sendable () -> ())? = nil) {
            self.title = title
            self.role = role
            self.action = action
        }
        
        static func == (lhs: Button, rhs: Button) -> Bool {
            lhs.title == rhs.title &&
            lhs.role == rhs.role
        }
    }
    
    let title: String
    let message: String?
    let buttons: [Button]
    let dismissAction: (@Sendable () -> ())?
    
    init(
        title: String,
        message: String? = nil,
        buttons: [Button],
        dismissAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.dismissAction = dismissAction
    }
    
    static func == (lhs: AlertModel, rhs: AlertModel) -> Bool {
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.buttons == rhs.buttons
    }
}

extension AlertModel.Button {
    private typealias L10n = Localizable.Alert
    
    static func ok() -> Self {
        Self(title: L10n.Button.ok)
    }
    
    static func cancel() -> Self {
        Self(title: L10n.Button.cancel)
    }
}

extension AlertModel {
    private typealias L10n = Localizable.Alert
    
    static func somethingWentWrong(dismiss: (@Sendable () -> ())? = nil) -> Self {
        Self(
            title: L10n.SomethingWentWrong.title,
            message: L10n.SomethingWentWrong.message,
            buttons: [.ok()],
            dismissAction: dismiss
        )
    }
    
    static func failure(message: String) -> Self {
            Self(
                title: L10n.Failure.title,
                message: message,
                buttons: [.ok()]
            )
        }
    
    static func findingTheNearestStationsFailed() -> Self {
        Self(
            title: L10n.FindingTheNearestStationsFailed.title,
            message: L10n.FindingTheNearestStationsFailed.message,
            buttons: [.ok()]
        )
    }
    
    static func locationServicesAuthorizationRestricted(_ coordinator: CoordinatorBase) -> Self {
        Self(title: L10n.LocationServicesAuthorizationRestricted.title, buttons: [.ok()])
    }
    
    @MainActor
    static func locationServicesAuthorizationDenied(_ coordinator: CoordinatorBase) -> Self {
        goToSettings(
            url: URL(string: UIApplication.openSettingsURLString),
            title: L10n.LocationServicesAuthorizationDenied.title,
            message: L10n.LocationServicesAuthorizationDenied.message,
            coordinator: coordinator
        )
    }
    
    static func locationServicesDisabled(_ coordinator: CoordinatorBase) -> Self {
        Self(
            title: L10n.LocationServicesAuthorizationRestricted.title,
            message: L10n.LocationServicesDisabled.message,
            buttons: [.ok()]
        )
    }
    
    @MainActor
    static func noInternetConnection(_ coordinator: CoordinatorBase) -> Self {
        goToSettings(
            url: URL(string: UIApplication.openSettingsURLString),
            title: L10n.NoInternetConnection.title,
            message: L10n.NoInternetConnection.message,
            coordinator: coordinator
        )
    }
    
    @MainActor
    private static func goToSettings(
        url: URL?,
        title: String,
        message: String? = nil,
        coordinator: CoordinatorBase,
        dismiss: (@Sendable () -> ())? = nil
    ) -> Self {
        let goToSettingsButton = AlertModel.Button(title: L10n.Button.goToSettings) {
            Task { @MainActor in
                coordinator.open(url: url)
            }
        }
        
        return Self(
            title: title,
            message: message,
            buttons: [goToSettingsButton, .cancel()],
            dismissAction: dismiss
        )
    }
}
