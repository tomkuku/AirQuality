//
//  AddObservedStationMapCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import SwiftUI

protocol CoordinatorNavigationComponentProtocol: Identifiable, Hashable where ID == String { }

extension CoordinatorNavigationComponentProtocol {
    var id: String {
        String(describing: self)
    }
}

extension AddObservedStationMapCoordinator {
    enum NavigationComponent: CoordinatorNavigationComponentProtocol {
        /// Delete this case when applay some navigation.
        /// This is only to avoid warning: 'navigationComponent' is of type 'AddObservedStationMapCoordinator.NavigationComponent' which cannot be constructed because it is an enum with no cases
        case `default`
    }
}

final class AddObservedStationMapCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    
    func startView() -> some View {
        AddObservedStationMapView()
            .environmentObject(self)
    }
    
    func createView(for navigationComponent: NavigationComponent) -> some View {
        assertionFailure("This method should be override!")
        return Rectangle()
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
    
    override func handleError(_ error: Error) {
        if let viewModelError = error as? AddObservedStationMapModel.ErrorType {
            switch viewModelError {
            case .findingTheNearestStationsFailed:
                showAlert(.findingTheNearestStationsFailed())
            }
        }
        
        super.handleError(error)
    }
}
