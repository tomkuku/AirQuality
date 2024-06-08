//
//  StationsListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import SwiftUI

struct StationsListView: View {
    
    private typealias L10n = Localizable
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel: StationsListViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if viewModel.stations.isEmpty {
                    Spacer()
                    
                    Text(L10n.AddStationListView.noData)
                    
                    Spacer()
                } else {
                    ForEach(viewModel.stations) { station in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(station.street ?? "")
                                
                                Text(station.cityName)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .accessibility(addTraits: [.isButton])
                        .gesture(TapGesture().onEnded {
                            coordinator.goToAddObservedStation()
//                            coordinator.gotSelectedStation(station)
                        })
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .navigationTitle(L10n.AddStationListView.title)
        }
        .taskOnFirstAppear {
            await viewModel.fetchStations()
        }
    }
    
    init(viewModel: StationsListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    NavigationStack {
        StationsListView(viewModel: .previewDummy)
            .navigationBarTitleDisplayMode(.inline)
    }
}
