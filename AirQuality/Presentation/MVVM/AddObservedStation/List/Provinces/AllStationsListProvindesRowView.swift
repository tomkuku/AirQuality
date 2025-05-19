//
//  AllStationsListProvindesRowView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import SwiftUI

struct AllStationsListProvindesRowView: View {
    
    // MARK: Body
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 10) {
                Text(province.name)
                    .font(.headline)
                    .foregroundStyle(Color.Text.primary)
                
                Spacer()
                
                HStack {
                    Text("\(province.numberOfStations)")
                        .font(.system(size: 20, weight: .regular))
                        .padding(.trailing, 8)
                    
                    Image.chevronCompactRight
                        .frame(width: 12, height: 12)
                        .scaledToFill()
                        .accessibilityIdentifier(\.allStationsListProvindesView.provindesListRow)
                }
                .foregroundStyle(Color.Text.secondary)
            }
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.gray.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .contentShape(Rectangle())
        .gesture(
            TapGesture()
                .onEnded { _ in
                    backgroundColor = .clear
                    coordinator.goTo(.provinceStations(provinceName: province.name, stations: province.stations))
                }
        )
    }
    
    // MARK: Properties
    
    private let province: AllStationsListProvindesModel.Province
    
    @EnvironmentObject private var coordinator: AddObservedStationListCoordinator
    @State private var backgroundColor: Color = .clear
    
    init(province: AllStationsListProvindesModel.Province) {
        self.province = province
    }
}
