//
//  AlertModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI

struct AlertModel: Sendable {
    struct Button: Sendable {
        let title: String
        let role: ButtonRole?
        let action: (@Sendable () -> ())?
        
        init(title: String, role: ButtonRole? = nil, action: (@Sendable () -> ())? = nil) {
            self.title = title
            self.role = role
            self.action = action
        }
    }
    
    let title: String
    let message: String?
    let buttons: [Button]
    let dimissAction: (@Sendable () -> ())?
    
    init(
        title: String,
        message: String? = nil,
        buttons: [Button],
        dimissAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.dimissAction = dimissAction
    }
}

extension AlertModel.Button {
    static func ok() -> Self {
        Self(title: NSLocalizedString("Alert.Button.Ok.title", comment: ""))
    }
}

extension AlertModel {
    static func somethigWentWrong(dismiss: (@Sendable () -> ())? = nil) -> Self {
        Self(
            title: NSLocalizedString("Alert.SomethingWentWrong.title", comment: ""),
            message: NSLocalizedString("Alert.SomethingWentWrong.message", comment: ""),
            buttons: [.ok()],
            dimissAction: dismiss
        )
    }
}
