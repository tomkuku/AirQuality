//
//  Publisher+Extension.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import Combine

extension Publisher where Output: Sendable, Failure == Never {
    func asyncSink(
        receiveValue: @escaping @Sendable (Self.Output) async -> Void
    ) -> AnyCancellable {
        self.sink { output in
            Task {
                await receiveValue(output)
            }
        }
    }
}

extension Publisher where Output: Sendable {
    func asyncSink(
        receiveCompletion: @Sendable @escaping (Subscribers.Completion<Self.Failure>) async -> Void,
        receiveValue: @Sendable @escaping (Self.Output) async -> Void
    ) -> AnyCancellable {
        sink { completion in
            Task {
                await receiveCompletion(completion)
            }
        } receiveValue: { value in
            Task {
                await receiveValue(value)
            }
        }
    }
}
