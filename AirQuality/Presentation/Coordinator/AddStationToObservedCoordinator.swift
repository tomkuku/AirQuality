//
//  AddStationToObservedCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import Foundation
import SwiftUI
import Combine

extension AddStationToObservedCoordinator {
    enum NavigationComponent: Identifiable {
        case statinsList
        case stationsMap
        
        var id: UUID {
            UUID()
        }
    }
}

final class AddStationToObservedCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    // MARK: Properties
    
    var fullScreenCover: NavigationComponent?
    
    var navigationComponentStart: NavigationComponent {
        .statinsList
    }
    
    // MARK: Private properties
    
    private var stationsListViewModel: AddStationToObservedListViewModel?
    private var stationsMapViewModel: AddObservedStationMapViewModel?
    
    // MARK: Methods
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        AddStationToObservedContainerView()
            .environmentObject(self)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .statinsList:
            let viewModel = getAddStationToObservedListViewModel()
            
            AddStationToObservedListView(viewModel: viewModel)
                .environmentObject(self)
        case .stationsMap:
            let viewModel = getAddObservedStationMapViewModel()
            
            AddObservedStationMapView(viewModel: viewModel)
                .environmentObject(self)
        }
    }
    
    // MARK: Private methods
    
    @MainActor
    private func getAddObservedStationMapViewModel() -> AddObservedStationMapViewModel {
        let viewModel: AddObservedStationMapViewModel
        
        if let stationsMapViewModel = self.stationsMapViewModel {
            viewModel = stationsMapViewModel
        } else {
            viewModel = AddObservedStationMapViewModel()
            self.stationsMapViewModel = viewModel
        }
        
        return viewModel
    }
    
    @MainActor
    private func getAddStationToObservedListViewModel() -> AddStationToObservedListViewModel {
        let viewModel: AddStationToObservedListViewModel
        
        if let stationsListViewModel = self.stationsListViewModel {
            viewModel = stationsListViewModel
        } else {
            viewModel = AddStationToObservedListViewModel()
            self.stationsListViewModel = viewModel
        }
        
        return viewModel
    }
}
