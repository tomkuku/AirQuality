//
//  BundleDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

protocol BundleDataSourceProtocol {
    func getData(of bundleFile: BundleFile) throws -> Data
}

final class BundleDataSource: BundleDataSourceProtocol {
    private let bundle: Bundle
    
    private var filesData: [BundleFile: Data] = [:]
    
    init(bundle: Bundle = .main) throws {
        self.bundle = bundle
        
        try loadDataOfAllBundleFilesToMemory()
    }
    
    func getData(of bundleFile: BundleFile) throws -> Data {
        guard let data = filesData[bundleFile] else {
            throw NSError(domain: "BundleRepository", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Data of file: \(bundleFile) not found!"
            ])
        }
        
        return data
    }
    
    // MARK: Private methods
    
    private func loadDataOfAllBundleFilesToMemory() throws {
        filesData = try BundleFile.allCases.reduce(into: [BundleFile: Data]()) {
            guard let url = bundle.url(forResource: $1.name, withExtension: $1.extension) else {
                throw NSError(domain: "BundleRepository", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "File \($1.name).\($1.extension) not found!"
                ])
            }
            
            // swiftlint:disable:next shorthand_argument
            $0[$1] = try Data(contentsOf: url)
        }
    }
}
