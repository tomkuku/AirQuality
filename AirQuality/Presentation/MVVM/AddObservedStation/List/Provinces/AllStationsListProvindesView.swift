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
    
    // MARK: Body
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            if viewModel.provinces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(L10n.noStations)
                    }
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.provinces) { province in
                        AllStationsListProvindesRowView(province: province)
                            .environmentObject(coordinator)
                    }
                }
                .listStyle(.inset)
                .refreshable {
                    try? await Task.sleep(for: .milliseconds(600))
                    
                    viewModel.fetchStations()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.navigationTitle)
        .transition(.opacity)
        .animation(.linear(duration: 0.2), value: viewModel.isLoading)
        .searchable(
            text: $viewModel.searchedText,
            prompt: L10n.seach
        )
        .doneToolbarButton {
            coordinator.dismiss()
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    // MARK: Private properties
    
    @EnvironmentObject private var coordinator: AddObservedStationListCoordinator
    @StateObject private var viewModel: AllStationsListProvincesViewModel
    
    // MARK: Lifecycle
    
    init(viewModel: @autoclosure @escaping () -> AllStationsListProvincesViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

// MARK: Preview

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, province: "Małopolskie"),
        .previewDummy(id: 2, province: "Zachodniopomorskie"),
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
