//
//  NotificationCenterProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation

protocol HasNotificationCenter {
    var notificationCenter: NotificationCenterProtocol { get }
}

protocol NotificationCenterProtocol: NotificationCenter { }

extension NotificationCenter: NotificationCenterProtocol { }
