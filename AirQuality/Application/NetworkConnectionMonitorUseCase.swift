//
//  NetworkConnectionMonitorUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 20/09/2024.
//

import Foundation

final class NetworkConnectionMonitorUseCase: Sendable {
    
    private let networkConnectionMonitorRepository: NetworkConnectionMonitorRepositoryProtocol
    
    init(
        networkConnectionMonitorRepository: NetworkConnectionMonitorRepositoryProtocol
    ) {
        self.networkConnectionMonitorRepository = networkConnectionMonitorRepository
    }
    
    func startMonitor(noConnectionBlock: @Sendable @escaping () -> ()) {
        Task { [weak self] in
            guard let self else { return }
            
            for await connection in self.networkConnectionMonitorRepository.startMonitoring()
            where !connection {
                noConnectionBlock()
            }
        }
    }
}
