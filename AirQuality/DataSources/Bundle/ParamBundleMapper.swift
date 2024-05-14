//
//  ParamBundleMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

struct ParamBundleMapper: MapperProtocol {
    func map(_ input: [ParamBundleModel]) throws -> [Param] {
        input.compactMap { paramBundleModel -> Param? in
            let indexLevel = Param.IndexLevels(
                veryGood: paramBundleModel.indexLevels.veryGood,
                good: paramBundleModel.indexLevels.good,
                moderate: paramBundleModel.indexLevels.moderate,
                sufficient: paramBundleModel.indexLevels.sufficient,
                bad: paramBundleModel.indexLevels.bad
            )
            
            guard let paramType = ParamType(rawValue: paramBundleModel.id) else {
                return nil
            }
            
            return Param(
                type: paramType,
                code: paramBundleModel.code,
                formula: paramBundleModel.formula,
                quota: paramBundleModel.quota,
                indexLevels: indexLevel
            )
        }
    }
}
