//
//  AddStationToObservedListView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import SwiftUI
import Combine

struct AddStationToObservedListView: View, Sendable {
    
    private typealias L10n = Localizable.AddObservedStationListView
    
    @EnvironmentObject private var coordinator: AddObservedStationListCoordinator
    @StateObject private var viewModel: AddStationToObservedListViewModel
    @State private var searchedText = ""
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.sections.isEmpty {
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
                        ForEach(viewModel.sections) { section in
                            SectionView(section: section, viewModel: viewModel)
                        }
                    }
                    .listStyle(.inset)
                }
            }
        }
        .onChange(of: searchedText) {
            viewModel.searchedTextDidChange(searchedText)
        }
        .searchable(text: $searchedText, placement: .navigationBarDrawer(displayMode: .always), prompt: L10n.seach)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.navigationTitle)
        .dimissToolbarButton {
            coordinator.dismiss()
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddStationToObservedListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1),
        .previewDummy(id: 2),
        .previewDummy(id: 3),
        .previewDummy(id: 4)
    ]
    
    @ObservedObject var viewModel = AddStationToObservedListViewModel()
    @ObservedObject var coordinator = AddObservedStationListCoordinator(coordinatorNavigationType: .presentation(dismissHandler: {}), alertSubject: .init(), toastSubject: .init())
    
    return TabView {
        NavigationStack {
            AddStationToObservedListView(viewModel: viewModel)
                .environmentObject(coordinator)
        }
    }
}
