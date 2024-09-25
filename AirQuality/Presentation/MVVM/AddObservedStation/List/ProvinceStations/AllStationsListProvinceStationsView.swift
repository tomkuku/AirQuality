//
//  AllStationsListProvinceStationsView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import SwiftUI
import Combine

struct AllStationsListProvinceStationsView: View {
    
    private typealias L10n = Localizable.AddObservedStationListView
    
    // MARK: Body
    
    var body: some View {
        List {
            ForEach(0..<viewModel.stations.count, id: \.self) { index in
                let row = viewModel.stations[index]
                AllStationsListProvinceStationsRowView(station: row.station, isObserved: row.isObserved)
            }
        }
        .listStyle(.inset)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(provinceName)
        .doneToolbarButton {
            coordinator.dismiss()
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    // MARK: Private properties
    
    private let provinceName: String
    private let stations: [Station]
    
    @State private var searchedText = ""
    @StateObject private var viewModel: AllStationListProvinceStationsViewModel
    @EnvironmentObject private var coordinator: AddObservedStationListCoordinator
    
    init(provinceName: String, stations: [Station]) {
        self.provinceName = provinceName
        self.stations = stations
        let viewModel = AllStationListProvinceStationsViewModel(allStationsInProvicne: stations)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    let stations: [Station] = [
        .previewDummy(id: 1, province: "Małopolskie"),
        .previewDummy(id: 2, province: "zachodniopomorskie"),
        .previewDummy(id: 3, province: "Mazowieckie"),
        .previewDummy(id: 4, province: "Opolskie")
    ]
    
    return TabView {
        NavigationStack {
            AllStationsListProvinceStationsView(provinceName: "Małopolskie", stations: stations)
        }
    }
}
