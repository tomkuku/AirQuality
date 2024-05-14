//
//  HTTPDataSource.swift
//
//
//  Created by Tomasz Kukułka on 25/04/2024.
//

import Foundation
import Alamofire

protocol HTTPDataSourceProtocol: Sendable {
    func requestData<T>(_ urlRequest: T) async throws -> Data where T: URLRequestConvertible
}

final class HTTPDataSource: HTTPDataSourceProtocol, @unchecked Sendable {
    private let session: Session
    private let queue = DispatchQueue(label: "com.http.data.source")
    
    init(sessionConfiguration: URLSessionConfiguration = .af.default) {
        self.session = Session(
            configuration: sessionConfiguration,
            rootQueue: queue,
            serializationQueue: queue,
            eventMonitors: [EventMonitorLogger()]
        )
    }
    
    func requestData<T>(_ urlRequest: T) async throws -> Data where T: URLRequestConvertible {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            
            session
                .request(urlRequest)
                .validate()
                .response(queue: queue) { response in
                    switch response.result {
                    case .success(let data):
                        guard let data else {
                            continuation.resume(throwing: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
                            return
                        }
                        
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

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
            body = String(data: data, encoding: .utf8) ?? "Body is empty"
        } else {
            body = "Body is empty"
        }
        
        let message = """
            Request didParseResponse
            URL: \(request.convertible)
            StatusCode: \(httpResponse.statusCode)
            Body: \n \(body)
        """
        
//        Logger.info(message)
    }
}
