//
//  AddStationToObservedContainerView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI
import Combine

struct AddStationToObservedContainerView: View {
    
    typealias L10n = Localizable.AddStationToObservedContainerView
    
    private enum Item: Int, Hashable {
        case list
        case map
    }
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    @State private var selctedTabItemIndex: Item = .list
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            TabView(selection: $selctedTabItemIndex) {
                coordinator.createView(for: .statinsList)
                    .tabItem {
                        Label(L10n.ListItem.itemTitle, systemImage: "text.justify")
                    }
                    .tag(Item.list)
                
                coordinator.createView(for: .stationsMap)
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

#Preview {
    // swiftlint:disable private_subject
    let alertSubject = PassthroughSubject<AlertModel, Never>()
    let toastSubject = PassthroughSubject<Toast, Never>()
    // swiftlint:enable private_subject
    
    let coordinator = AddStationToObservedCoordinator(
        dimissHandler: {},
        alertSubject: alertSubject,
        toastSubject: toastSubject
    )
    
    return AddStationToObservedContainerView()
        .environmentObject(coordinator)
}
