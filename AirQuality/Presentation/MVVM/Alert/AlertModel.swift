//
//  AlertModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI

struct AlertModel: Sendable, Equatable {
    struct Button: Sendable, Equatable {
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
    static func ok() -> Self {
        Self(title: Localizable.Alert.Button.Ok.title)
    }
    
    static func cancel() -> Self {
        Self(title: Localizable.Alert.Button.Cancel.title)
    }
}

extension AlertModel {
    static func somethigWentWrong(dismiss: (@Sendable () -> ())? = nil) -> Self {
        Self(
            title: Localizable.Alert.SomethingWentWrong.title,
            message: Localizable.Alert.SomethingWentWrong.message,
            buttons: [.ok()],
            dismissAction: dismiss
        )
    }
}
