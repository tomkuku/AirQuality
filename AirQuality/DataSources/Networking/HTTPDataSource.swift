//
//  HTTPDataSource.swift
//
//
//  Created by Tomasz Kukułka on 25/04/2024.
//

import Foundation
import Alamofire
import Combine

protocol HTTPDataSourceProtocol: Sendable {
    func requestData<T>(_ urlRequest: T) async throws -> Data where T: HTTPRequest
}

actor HTTPDataSource: HTTPDataSourceProtocol {
    private let session: Session
    private let queue = DispatchQueue(label: "com.http.data.source")
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionConfiguration: URLSessionConfiguration = .af.default) {
        var eventMonitors: [EventMonitor] = []
        
#if DEBUG
        if !ProcessInfo.isTest {
            eventMonitors.append(EventMonitorLogger())
        }
        
        if ProcessInfo.processInfo.arguments.contains("-local_mock") {
            
        }
#endif
        
        self.session = Session(
            configuration: sessionConfiguration,
            rootQueue: queue,
            serializationQueue: queue,
            eventMonitors: eventMonitors
        )
    }
    
    func requestData<T>(_ urlRequest: T) async throws -> Data where T: HTTPRequest {
        try await withCheckedThrowingContinuation { continuation in
            session
                .request(urlRequest)
                .validate()
                .publishData(queue: self.queue)
                .tryMap {
                    switch $0.result {
                    case .success(let data):
                        return data
                    case .failure(let error):
                        throw error
                    }
                }
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    continuation.resume(throwing: error)
                } receiveValue: { data in
                    continuation.resume(returning: data)
                }
                .store(in: &cancellables)
        }
    }
}

#if DEBUG
final class EventMonitorLogger: EventMonitor {
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        guard
            let data = response.data,
            let httpResponse = response.response
        else {
            return
        }
        
        let body: String
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            body = String(decoding: data, as: UTF8.self)
        } else {
            body = "Body is empty"
        }
        
        let message = """
            Request didParseResponse
            URL: \(request.convertible)
            StatusCode: \(httpResponse.statusCode)
            Body: \n \(body)
        """
        
        Logger.info(message)
    }
}
#endif
