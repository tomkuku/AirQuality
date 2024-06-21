//
//  BundleRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

protocol HasParamsRepository {
    var paramsRepository: ParamsRepositoryProtocol { get }
}

protocol ParamsRepositoryProtocol: Sendable {
    func getParam(withId id: Int) -> Param?
}

final class ParamsRepository: ParamsRepositoryProtocol, @unchecked Sendable {
    private let bundleDataSource: BundleDataSourceProtocol
    private let jsonDecoder = JSONDecoder()
    
    private var params: [Param] = []
    
    init(bundleDataSource: BundleDataSourceProtocol) throws {
        self.bundleDataSource = bundleDataSource
        
        try loadAllParams()
    }
    
    func getParam(withId id: Int) -> Param? {
        params.first(where: { $0.type.rawValue == id })
    }
    
    private func loadAllParams() throws {
        let data = try bundleDataSource.getData(of: .paramsInfo)
        let params = try jsonDecoder.decode([ParamBundleModel].self, from: data)
        self.params = try ParamBundleMapper().map(params)
    }
}
