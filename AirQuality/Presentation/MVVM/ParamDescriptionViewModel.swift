//
//  ParamDescriptionViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/08/2025.
//

import Foundation

final class ParamDescriptionViewModel: ObservableObject {
    
    private(set) var elements: [ParamDescriptionModel.ParamInfo]
    
    init() {
        elements = [
            .init(
                param: .c6h6,
                descriptions: [
                    .general(Localizable.Param.C6h6.Description.general),
                    .environmentalImpact(Localizable.Param.C6h6.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.C6h6.Description.humanHealthImpact)
                ]
            ),
            .init(
                param: .pm10,
                descriptions: [
                    .general(Localizable.Param.Pm10.Description.general),
                    .environmentalImpact(Localizable.Param.Pm10.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.Pm10.Description.humanHealthImpact)
                ]
            ),
            .init(
                param: .pm25,
                descriptions: [
                    .general(Localizable.Param.Pm25.Description.general),
                    .environmentalImpact(Localizable.Param.Pm25.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.Pm25.Description.humanHealthImpact)
                ]
            ),
            .init(
                param: .o3,
                descriptions: [
                    .general(Localizable.Param.O3.Description.general),
                    .environmentalImpact(Localizable.Param.O3.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.O3.Description.humanHealthImpact)
                ]
            ),
            .init(
                param: .so2,
                descriptions: [
                    .general(Localizable.Param.So2.Description.general),
                    .environmentalImpact(Localizable.Param.So2.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.So2.Description.humanHealthImpact)
                ]
            ),
            .init(
                param: .co,
                descriptions: [
                    .general(Localizable.Param.Co.Description.general),
                    .environmentalImpact(Localizable.Param.Co.Description.environmentalImpact),
                    .humanHealthImpact(Localizable.Param.Co.Description.humanHealthImpact)
                ]
            )
        ]
    }
}
