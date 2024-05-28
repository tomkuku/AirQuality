//
//  AddStationToObservedListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI
import Combine

struct AddStationToObservedListView: View, Sendable {
    
    private typealias L10n = Localizable.AddStationToObservedListView
    
    @EnvironmentObject private var coordinator: AddStationToObservedCoordinator
    @StateObject private var viewModel: AddStationToObservedListViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if viewModel.stations.isEmpty {
                    Spacer()
                    
//                    Text(L10n.AddStationListView.noData)
                    
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
                            viewModel.observeStation(station)
                        })
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .navigationTitle(L10n.title)
        }
        .onReceive(viewModel.errorPublisher) { _ in
            coordinator.showAlert(.somethigWentWrong())
        }
        .taskOnFirstAppear {
            Task { @HandlerActor in
                await viewModel.fetchStations()
            }
        }
    }
    
    init(viewModel: AddStationToObservedListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
