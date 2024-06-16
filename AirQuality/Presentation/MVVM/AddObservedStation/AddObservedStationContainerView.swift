//
//  AddObservedStationContainerView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI
import Combine

struct AddObservedStationContainerView: View {
    
    private typealias L10n = Localizable.AddObservedStationContainerView
    
    private enum Item: Int, Hashable {
        case list
        case map
    }
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    @State private var selctedTabItemIndex: Item = .list
    
    var body: some View {
        TabView(selection: $selctedTabItemIndex) {
            CoordinatorInitialNavigationView(coordinator: coordinator.addObservedStationListCoordinator, showAlerts: false, showToasts: false)
                .tabItem {
                    Label(L10n.ListItem.itemTitle, systemImage: "text.justify")
                }
                .tag(Item.list)
            
            CoordinatorInitialNavigationView(coordinator: coordinator.addObservedStationMapCoordinator, showAlerts: false, showToasts: false)
                .tabItem {
                    Label(L10n.MapItem.itemTitle, systemImage: "map")
                }
                .tag(Item.map)
        }
    }
}

//#Preview {
//    // swiftslint:disable private_subject
//    let alertSubject = PassthroughSubject<AlertModel, Never>()
//    let toastSubject = PassthroughSubject<Toast, Never>()
//    // swiftslint:enable private_subject
//
//    let coordinator = AddStationToObservedCoordinator(
//        dimissHandler: {},
//        alertSubject: alertSubject,
//        toastSubject: toastSubject
//    )
//    
//    return AddStationToObservedContainerView()
//        .environmentObject(coordinator)
//}
