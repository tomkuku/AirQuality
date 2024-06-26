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
                            let imageColor: Color = row.isStationObserved ? .blue : .gray
                            
                            (row.isStationObserved ? Image.checkmarkCircleFill : Image.circle)
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
        viewModel: AddStationToObservedListViewModel,
        onSelectedStation: @escaping (Station) -> ()
    ) {
        self.section = section
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onSelectedStation = onSelectedStation
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
    @ObservedObject var coordinator = AddObservedStationListCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {})
    )
    
    return AddStationToObservedListView(viewModel: viewModel)
                .environmentObject(coordinator)
}
