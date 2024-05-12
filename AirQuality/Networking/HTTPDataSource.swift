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

public final class HTTPDataSource: HTTPDataSourceProtocol, @unchecked Sendable {
    private let session: Session
    private let queue = DispatchQueue(label: "com.http.data.source")
    
    public init(session: Session = .default) {
        self.session = session
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
