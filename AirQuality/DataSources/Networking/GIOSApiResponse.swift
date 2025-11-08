//
//  GIOSApiResponse.swift
//  Networking
//
//  Created by Tomasz Kukułka on 27/04/2024.
//

import Foundation

enum GIOSApiV1 {
    enum ContainerName: String, CaseIterable, CodingKey {
        case stations = "Lista stacji pomiarowych"
        case sensors = "Lista stanowisk pomiarowych dla podanej stacji"
        case measurements = "Lista danych pomiarowych"
        case archivalMeasurements = "Lista archiwalnych wyników pomiarów"
    }
    
    struct Response<Content>: Decodable where Content: Decodable {
        private struct DynamicKey: CodingKey {
            var stringValue: String
            var intValue: Int?
            
            init?(intValue: Int) {
                stringValue = "nil"
            }
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
        }
        
        private enum StaticKeys: String, CodingKey {
            case totalPages
        }
        
        let content: Content
        let totalPages: Int
        
        init(from decoder: any Decoder) throws {
            let staticContainer = try decoder.container(keyedBy: StaticKeys.self)
            let dynamicContainer = try decoder.container(keyedBy: DynamicKey.self)
            
            let contentKey = dynamicContainer.allKeys.first(where: {
                GIOSApiV1.ContainerName.allCases.map(\.rawValue).contains($0.stringValue)
            })
            
            guard let contentKey else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Object does not contain any of the expected keys!"
                    )
                )
            }
            
            self.content = try dynamicContainer.decode(Content.self, forKey: contentKey)
            self.totalPages = try staticContainer.decode(Int.self, forKey: .totalPages)
        }
    }
}
