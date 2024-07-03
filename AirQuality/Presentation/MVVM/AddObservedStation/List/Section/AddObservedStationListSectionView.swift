//
//  AddObservedStationListSectionView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import SwiftUI

struct SectionView: View {
    @State private var isShrunk = false
    @ObservedObject private var viewModel: AddStationToObservedListViewModel
    
    private let section: AddStationToObservedListModel.Section
    
    var body: some View {
        Section {
            if isShrunk {
                EmptyView()
            } else {
                ForEach(section.rows) { row in
                    AllStationsListRowView(station: row.station, isStationObserved: row.isStationObserved)
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
                    Image.chevronDown
                        .accessibility(hidden: true)
                        .rotationEffect(.degrees(isShrunk ? 0 : 180))
                    
                    if isShrunk {
                        Text(Localizable.AddObservedStationListView.ShrinkButton.expand)
                    } else {
                        Text(Localizable.AddObservedStationListView.ShrinkButton.shrink)
                    }
                }
            }
        }
    }
    
    init(
        section: AddStationToObservedListModel.Section,
        viewModel: AddStationToObservedListViewModel
    ) {
        self.section = section
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    private func createRow(for station: Station) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(station.street ?? "")
            
            Text(station.cityName)
        }
    }
}

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1),
        .previewDummy(id: 2),
        .previewDummy(id: 3),
        .previewDummy(id: 4)
    ]
    
    GetStationSensorsParamsUseCasePreviewDummy.getParamsResult = [.c6h6, .pm10, .pm25, .so2, .co, .no2, .o3]
    
    @ObservedObject var viewModel = AddStationToObservedListViewModel()
    @ObservedObject var coordinator = AddObservedStationListCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {})
    )
    
    return AddStationToObservedListView(viewModel: viewModel)
        .environmentObject(coordinator)
}
