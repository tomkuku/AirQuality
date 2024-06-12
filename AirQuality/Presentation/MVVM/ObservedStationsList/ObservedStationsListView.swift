//
//  ObservedStationsListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import SwiftUI

struct ObservedStationsListView: View {
    
    private typealias L10n = Localizable
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel: StationsListViewModel
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            ZStack {
                if viewModel.stations.isEmpty {
                    Spacer()
                    
                    Text(L10n.AddStationListView.noData)
                    
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.stations) { station in
                            createStationRow(station)
                        }
                    }
                    .listStyle(.sidebar)
                    .background(.white)
                }
                
                addObservedStationsButton
            }
            .navigationTitle(L10n.AddStationListView.title)
        }
    }
    
    private var addObservedStationsButton: some View {
        VStack {
            Spacer()
            
            Button {
                coordinator.goTo(.addNewObservedStation)
            } label: {
                Text("Dodaj stacje")
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .black.opacity(0.3), radius: 16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    init(viewModel: @autoclosure @escaping () -> StationsListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
    
    private func createStationRow(_ station: Station) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(station.street ?? "")
                
                Text(station.cityName)
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            Rectangle()
                .foregroundStyle(.clear)
        }
        .background(Color.white)
        .accessibility(addTraits: [.isButton])
        .gesture(TapGesture().onEnded {
            coordinator.goTo(.slectedStation(station))
        })
        .swipeActions {
            Button("Usuń", role: .destructive) {
                viewModel.deletedObservedStation(station)
            }
        }
    }
}

struct ObservedStationsListView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator(coordinatorNavigationType: .presentation(dismissHandler: {}))
        @Injected(\.addObservedStationUseCase) var addObservedStationUseCase
        
        Task {
            do {
                try await addObservedStationUseCase.add(station: Station.previewDummy())
            } catch {
                
            }
        }
        
        return NavigationStack {
            ObservedStationsListView()
                .environmentObject(appCoordinator)
                .navigationTitle("Lista Stacji")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
