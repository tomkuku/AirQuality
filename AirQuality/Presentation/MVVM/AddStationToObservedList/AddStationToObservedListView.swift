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
        .navigationTitle(L10n.title)
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

extension AddStationToObservedListView {
    struct SectionView: View {
        @State private var isShrunk = false
        @ObservedObject private var viewModel: AddStationToObservedListViewModel
        
        private let section: AddStationToObservedListModel.Section
        private let onSelectedStation: (Station) -> ()
        
        var body: some View {
            Section {
                if isShrunk {
                    EmptyView()
                        .frame(width: .zero, height: .zero)
                } else {
                    ForEach(section.rows) { row in
                        HStack {
                            ZStack {
                                let imageName = row.isStationObserved ? "checkmark.circle.fill" : "circle"
                                let imageColor: Color = row.isStationObserved ? .blue : .gray
                                
                                Image(systemName: imageName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .foregroundStyle(imageColor)
                                    .accessibilityHidden(true)
                            }
                            .padding(.trailing, 16)
                            .accessibility(addTraits: [.isButton])
                            .gesture(TapGesture().onEnded {
                                onSelectedStation(row.station)
                            })
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(row.station.street ?? "")
                                    
                                    Text(row.station.cityName)
                                }
                            }
                        }
                    }
                }
            } header: {
                shinkButton
            }
        }
        
        private var shinkButton: some View {
            HStack {
                Text(section.name)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isShrunk.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                            .accessibility(hidden: true)
                            .rotationEffect(.degrees(isShrunk ? 0 : 180))
                        
                        if isShrunk {
                            Text(Localizable.AddStationToObservedListView.ShrinkButton.expand)
                        } else {
                            Text(Localizable.AddStationToObservedListView.ShrinkButton.shrink)
                        }
                    }
                }
            }
        }
        
        init(
            section: AddStationToObservedListModel.Section,
            viewModel: AddStationToObservedListViewModel,
            onSelectedStation: @escaping (Station) -> ()
        ) {
            self.section = section
            self._viewModel = ObservedObject(wrappedValue: viewModel)
            self.onSelectedStation = onSelectedStation
        }
    }
}
