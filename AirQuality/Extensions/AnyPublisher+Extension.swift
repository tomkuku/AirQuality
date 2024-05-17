//
//  AnyPublisher+Extension.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import Combine

extension AnyPublisher where Failure == Never {
    func createAsyncStream(_ cancellables: inout Set<AnyCancellable>) -> AsyncStream<Output> {
        AsyncStream { continuation in
            self.sink {
                guard case .finished = $0 else { return }
                
                continuation.finish()
            } receiveValue: {
                continuation.yield($0)
            }
            .store(in: &cancellables)
        }
    }
}
