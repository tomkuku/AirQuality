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
        if !ProcessInfo.isUnitTests {
            eventMonitors.append(EventMonitorLogger())
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
    func requestDidResume(_ request: Request) {
        let requestUrl = "\(request.request?.httpMethod?.uppercased() ?? "") \(request.request?.url?.path() ?? "none")"
        
        let message =
        """
        ⬆️ Request: \(request.id) \(requestUrl)
        """
        
        Logger.info(message)
    }
    
    func request(
        _ request: DataRequest,
        didValidateRequest urlRequest: URLRequest?,
        response: HTTPURLResponse,
        data: Data?,
        withResult result: Request.ValidationResult
    ) {
        let body: String
        
        if let data,
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let _body = String(data: data, encoding: .utf8) {
            body = _body
        } else {
            body = "Body is empty"
        }
        
        let requestUrl = "\(request.request?.httpMethod?.uppercased() ?? "") \(request.request?.url?.absoluteString ?? "none")"
        
        let message =
        """
        ⬇️ Response: \(request.id) \(requestUrl)
           StatusCode: \(response.statusCode)
           Body: \n \(body)
        """
        
        Logger.info(message)
    }
}
#endif
