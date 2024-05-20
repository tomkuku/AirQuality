//
//  GIOSApiResponse.swift
//  Networking
//
//  Created by Tomasz Kukułka on 27/04/2024.
//

import Foundation

struct GIOSApiV1Response: Decodable {
    struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            stringValue = "nil"
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    private let container: KeyedDecodingContainer<Self.DynamicKey>
    
    init(from decoder: any Decoder) throws {
        self.container = try decoder.container(keyedBy: DynamicKey.self)
    }
    
    func getValue<T>(for key: String) throws -> T where T: Decodable {
        guard let codingKey = container.allKeys.first(where: { $0.stringValue == key }) else {
            throw NSError(domain: "GIOSApiResponse", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Key \"\(key)\" not found in keys list: \(container.allKeys)"
            ])
        }
        
        return try container.decode(T.self, forKey: codingKey)
    }
}
