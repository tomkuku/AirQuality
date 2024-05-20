//
//  BundleFile.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

struct BundleFile: Hashable, CaseIterable {
    let name: String
    let `extension`: String
    
    private init(name: String, `extension`: String) {
        self.name = name
        self.extension = `extension`
    }
    
    static let allCases: [BundleFile] = [paramsInfo]
    static let paramsInfo = Self(name: "ParamsInfo", extension: "json")
}
