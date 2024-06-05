//
//  NotificationCenterSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation

@testable import AirQuality

final class NotificationCenterSpy: NotificationCenterProtocol, @unchecked Sendable {
    
    enum Event: Equatable, Sendable, Hashable {
        case post(NSNotification.Name)
        case publisher(Notification.Name)
    }
    
    var events: [Event] = []
    let notificationCenter: NotificationCenter
    private let queue = DispatchQueue(label: "com.notification.center.spy")
    
    init(notificationCenter: NotificationCenter = .init()) {
        self.notificationCenter = notificationCenter
    }
    
    func post(name aName: NSNotification.Name, object anObject: Any?) {
        queue.sync {
            events.append(.post(aName))
        }
        notificationCenter.post(name: aName, object: anObject)
    }
    
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher {
        queue.sync {
            events.append(.publisher(name))
        }
        return notificationCenter.publisher(for: name, object: object)
    }
    
    func notifications(named name: Notification.Name, object: AnyObject?) -> NotificationCenter.Notifications {
        queue.sync {
            events.append(.publisher(name))
        }
        return notificationCenter.notifications(named: name, object: object)
    }
}
