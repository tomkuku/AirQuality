//
//  AllStationsListProvinceStationsRowView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import SwiftUI

struct AllStationsListProvinceStationsRowView: View {
    
    // MARK: Body
    
    var body: some View {
        HStack {
            Button {
                if isObserved {
                    viewModel.deletedObservedStation(station)
                } else {
                    viewModel.addObservedStation(station)
                }
            } label: {
                ZStack {
                    let imageColor: Color = isObserved ? .blue : .gray
                    
                    Group {
                        if isObserved {
                            Image.checkmarkCircleFill
                                .resizable()
                                .renderingMode(.template)
                                .accessibilityIdentifier(AccessibilityIdentifiers.AllStationsListProvinceStationsRowView.isObserved.rawValue)
                        } else {
                            Image.circle
                                .resizable()
                                .renderingMode(.template)
                                .accessibilityIdentifier(AccessibilityIdentifiers.AllStationsListProvinceStationsRowView.isNotObserved.rawValue)
                        }
                    }
                    .frame(width: 24, height: 24, alignment: .center)
                    .accessibilityHidden(true)
                    .foregroundStyle(imageColor)
                }
            }
            .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(station.street ?? "")
                    .font(.headline)
                    .foregroundStyle(Color.Text.primary)
                
                Text(station.cityName)
                    .font(.subheadline)
                    .foregroundStyle(Color.Text.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.Background.primary)
    }
    
    // MARK: Private properties
    
    @StateObject private var viewModel: AllStationStationViewModel
    
    private let isObserved: Bool
    private let station: Station
    
    init(station: Station, isObserved: Bool) {
        self.station = station
        self.isObserved = isObserved
        let viewModel = AllStationStationViewModel(station: station)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    let stations: [Station] = [
        .previewDummy(id: 1, province: "Małopolskie"),
        .previewDummy(id: 2, province: "zachodniopomorskie"),
        .previewDummy(id: 3, province: "Mazowieckie"),
        .previewDummy(id: 4, province: "Opolskie")
    ]
    
    return TabView {
        NavigationStack {
            AllStationsListProvinceStationsView(provinceName: "Małopolskie", stations: stations)
        }
    }
}
