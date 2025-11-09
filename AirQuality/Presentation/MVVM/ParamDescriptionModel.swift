//
//  ParamDescriptionModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/08/2025.
//

import Foundation

enum ParamDescriptionModel {
    struct ParamInfo {
        let param: Param
        let descriptions: [Description]
        
        init(param: Param, descriptions: [Description]) {
            self.param = param
            self.descriptions = descriptions
        }
    }
    
    enum Description: Identifiable, Equatable {
        case general(String)
        case environmentalImpact(String)
        case humanHealthImpact(String)
        
        var id: Int {
            switch self {
            case .general:
                0
            case .environmentalImpact:
                1
            case .humanHealthImpact:
                2
            }
        }
        
        var title: String {
            switch self {
            case .general:
                Localizable.ParamDescriptionView.Element.Title.general
            case .environmentalImpact:
                Localizable.ParamDescriptionView.Element.Title.environmentalImpact
            case .humanHealthImpact:
                Localizable.ParamDescriptionView.Element.Title.humanHealthImpact
            }
        }
        
        var description: String {
            switch self {
            case .general(let description):
                return description
            case .environmentalImpact(let description):
                return description
            case .humanHealthImpact(let description):
                return description
            }
        }
    }
}

extension ParamDescriptionModel.ParamInfo: Identifiable {
    var id: String {
        param.code
    }
}

extension ParamDescriptionModel.ParamInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(param.code)
    }
}
