//
//  AllStationsListProvindesView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import SwiftUI
import Combine

struct AllStationsListProvindesView: View {
    
    private typealias L10n = Localizable.AddObservedStationListView
    
    @EnvironmentObject private var coordinator: AddObservedStationListCoordinator
    @StateObject private var viewModel: AllStationsListProvincesViewModel
    @State private var searchedText = ""
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.provinces.isEmpty {
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(L10n.noStations)
                    }
                    
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.provinces) { province in
                            AllStationsListProvindesRowView(province: province)
                                .environmentObject(coordinator)
                        }
                    }
                    .listStyle(.inset)
                }
            }
        }
        .refreshable {
            viewModel.fetchStations()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.navigationTitle)
        .doneToolbarButton {
            coordinator.dismiss()
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AllStationsListProvincesViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, province: "Małopolskie"),
        .previewDummy(id: 2, province: "zachodniopomorskie"),
        .previewDummy(id: 3, province: "Mazowieckie"),
        .previewDummy(id: 4, province: "Opolskie")
    ]
    
    @ObservedObject var viewModel = AllStationsListProvincesViewModel()
    @ObservedObject var coordinator = AddObservedStationListCoordinator(coordinatorNavigationType: .presentation(dismissHandler: {}), alertSubject: .init(), toastSubject: .init())
    
    return TabView {
        NavigationStack {
            AllStationsListProvindesView(viewModel: viewModel)
                .environmentObject(coordinator)
        }
    }
}
