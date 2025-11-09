//
//  WireMockClient.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 08/11/2025.
//

import Foundation
import XCTest

@testable import AirQuality

final class WireMockClient {
    
    private let urlSession = URLSession.shared
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        return encoder
    }()
    
    private let wireMockAdminUrl = URL(string: "http://localhost:8080/__admin/mappings")!
    
    func addResponse<T>(
        responseContent: T,
        totalPages: Int,
        for request: any HTTPRequest
    ) async throws where T: Encodable {
        let giosApiV1Response = GIOSApiV1Response(
            content: responseContent,
            totalPages: totalPages,
            codingKey: getContainerName(for: request)
        )
        
        let wireMockServerRequestData = try createWireMockServerRequestData(
            giosApiV1Response: giosApiV1Response,
            for: request
        )
        
        let wireMockServerRequest = try createWireMockServerRequest(with: wireMockServerRequestData)
        let wireMockServerResponse = try await urlSession.data(for: wireMockServerRequest)
        
        guard let httpUrlResponse = wireMockServerResponse.1 as? HTTPURLResponse else {
            XCTFail("Casting URLResponse to HTTPURLResponse failed!")
            return
        }
        
        guard Array(200...299).contains(httpUrlResponse.statusCode) else {
            XCTFail("WireMock returned non-2XX status code!")
            return
        }
    }
    
    private func createWireMockServerRequestData<T>(
        giosApiV1Response: T,
        for request: any HTTPRequest
    ) throws -> Data where T: Encodable {
        let url = try request.asURLRequest().url!
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let urlPath = urlComponents.path
        let queryParameters = urlComponents.queryItems?.reduce(into: [String: any Encodable]()) {
            $0[$1.name] = $1.value
        } ?? [:]
        
        let wireMockMappingRequest = WireMockMapping<T>.Request(method: "GET", urlPath: urlPath, queryParameters: queryParameters)
        let wireMockMappingResponse = WireMockMapping<T>.Response(statusCode: 200, jsonBody: giosApiV1Response)
        let wireMockMapping = WireMockMapping<T>(request: wireMockMappingRequest, response: wireMockMappingResponse)
        
        return try jsonEncoder.encode(wireMockMapping)
    }
    
    private func createWireMockServerRequest(with data: Data) throws -> URLRequest {
        var urlRequest = try URLRequest(
            url: wireMockAdminUrl,
            method: .post,
            headers: ["Content-Type": "application/json"]
        )
        urlRequest.httpBody = data
        
        return urlRequest
    }
    
    private func getContainerName(for request: any HTTPRequest) -> GIOSApiV1.ContainerName {
        switch request {
        case is Endpoint.Stations:
            return GIOSApiV1.ContainerName.stations
        case is Endpoint.Sensors:
            return GIOSApiV1.ContainerName.sensors
        case is Endpoint.Measurements:
            return GIOSApiV1.ContainerName.measurements
        case is Endpoint.ArchivalMeasurements:
            return GIOSApiV1.ContainerName.archivalMeasurements
        default:
            XCTFail("Request does not match to any known Endpoint!")
            return GIOSApiV1.ContainerName.stations
        }
    }
}

struct GIOSApiV1Response<Content>: Encodable where Content: Encodable {
    let content: Content
    let totalPages: Int
    let codingKey: GIOSApiV1.ContainerName
    
    private enum TotalPageKey: String, CodingKey {
        case totalPages
    }
    
    func encode(to encoder: any Encoder) throws {
        var contentContainer = encoder.container(keyedBy: GIOSApiV1.ContainerName.self)
        try contentContainer.encode(content, forKey: codingKey)
        
        var totalPagesContainer = encoder.container(keyedBy: TotalPageKey.self)
        try totalPagesContainer.encode(totalPages, forKey: .totalPages)
    }
}

struct WireMockMapping<T>: Encodable where T: Encodable {
    struct Request: Encodable {
        struct CodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?
            
            init?(intValue: Int) {
                stringValue = "nil"
            }
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            static var method: Self { Self(stringValue: "method")! }
            static var urlPath: Self { Self(stringValue: "urlPath")! }
            static var queryParameters: Self { Self(stringValue: "queryParameters")! }
            static var equalTo: Self { Self(stringValue: "equalTo")! }
        }
        
        let method: String
        let urlPath: String
        let queryParameters: [String: any Encodable]
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(method, forKey: .method)
            try container.encode(urlPath, forKey: .urlPath)
            
            var queryParametersContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .queryParameters)
            
            try queryParameters.forEach {
                var paramContainer = queryParametersContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: CodingKeys(stringValue: $0.key)!)
                try paramContainer.encode($0.value, forKey: .equalTo)
            }
        }
    }
    
    struct Response: Encodable {
        enum CodingKeys: String, CodingKey {
            case statusCode = "status"
            case jsonBody
        }
        
        let statusCode: Int
        let jsonBody: T
    }
    
    let request: Request
    let response: Response
}
