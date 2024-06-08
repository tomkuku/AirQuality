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
        BaseView(viewModel: viewModel, coordinator: coordinator) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.sections.isEmpty {
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(Localizable.AddStationToObservedListView.noStations)
                    }
                    
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.sections) { section in
                            SectionView(section: section, viewModel: viewModel) { station in
                                viewModel.stationDidSelect(station)
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
        }
        .taskOnFirstAppear {
            viewModel.fetchStations()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AddStationToObservedListViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}
