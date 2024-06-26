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
                    Label(
                        title: { Text(L10n.ListItem.itemTitle) },
                        icon: { Image.textJustify }
                    )
                }
                .tag(Item.list)
            
            CoordinatorInitialNavigationView(coordinator: coordinator.addObservedStationMapCoordinator, showAlerts: false, showToasts: false)
                .tabItem {
                    Label(
                        title: { Text(L10n.MapItem.itemTitle) },
                        icon: { Image.map }
                    )
                }
                .tag(Item.map)
        }
    }
}

#Preview {
    @StateObject var addStationToObservedCoordinator = AddStationToObservedCoordinator(coordinatorNavigationType: .presentation(dismissHandler: {}))
    
    return AddObservedStationContainerView()
        .environmentObject(addStationToObservedCoordinator)
}
