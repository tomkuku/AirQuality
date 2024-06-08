//
//  AddObservedStationContainerView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI
import Combine

struct AddObservedStationContainerView: View {
    
    typealias L10n = Localizable.AddStationToObservedContainerView
    
    private enum Item: Int, Hashable {
        case list
        case map
    }
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    @State private var selctedTabItemIndex: Item = .list
    
    var body: some View {
        TabView(selection: $selctedTabItemIndex) {
            AddStationToObservedListView()
                .tabItem {
                    Label(L10n.ListItem.itemTitle, systemImage: "text.justify")
                }
                .tag(Item.list)
            
            AddObservedStationMapView()
                .tabItem {
                    Label(L10n.MapItem.itemTitle, systemImage: "map")
                }
                .tag(Item.map)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(navigationTitle)
        .toolbar {
            Button(action: {
                coordinator.dismiss()
            }, label: {
                Text(L10n.closeButton)
            })
        }
    }
    
    private var navigationTitle: String {
        switch selctedTabItemIndex {
        case .list:
            L10n.ListItem.navigationTitle
        case .map:
            L10n.MapItem.navigationTitle
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
