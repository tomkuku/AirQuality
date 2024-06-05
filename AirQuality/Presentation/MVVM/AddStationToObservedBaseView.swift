//
//  AddStationToObservedBaseView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI

struct AddStationToObservedBaseView: View {
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            TabView {
                AddStationToObservedListView()
                    .environmentObject(coordinator)
            }
        }
    }
}
