//
//  AllStationsListRowView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/07/2024.
//

import SwiftUI

struct AllStationsListRowView: View {
    @State private var isExpanded = false
    @StateObject private var viewModel: AllStationStationViewModel
    
    private let station: Station
    private let isStationObserved: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if isStationObserved {
                        viewModel.deletedObservedStation(station)
                    } else {
                        viewModel.addObservedStation(station)
                    }
                } label: {
                    VStack {
                        ZStack {
                            let imageColor: Color = isStationObserved ? .blue : .gray
                            
                            (isStationObserved ? Image.checkmarkCircleFill : Image.circle)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundStyle(imageColor)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(.trailing, 16)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(station.street ?? "")
                        
                        Text(station.cityName)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded {
                            withAnimation(.linear(duration: 0.5)) {
                                isExpanded.toggle()
                            }
                        }
                )
            }
            
            if isExpanded {
                ParamsView(station: station)
                    .padding(.leading, 48)
                    .transition(.opacity)
                    .gesture(DragGesture().exclusively(before: TapGesture()))
            }
        }
        .padding(.vertical, 8)
    }
    
    init(station: Station, isStationObserved: Bool) {
        self.station = station
        self.isStationObserved = isStationObserved
        let viewModel = AllStationStationViewModel(station: station)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let station = Station.previewDummy()
    
    let viewModel = AllStationStationViewModel(station: station)
    
    @Namespace var namespace
    
    return VStack {
        Rectangle()
            .foregroundStyle(.blue)
        
        AllStationsListRowView(station: station, isStationObserved: true)
        .previewLayout(PreviewLayout.sizeThatFits)
        
        Rectangle()
            .foregroundStyle(.red)
    }
    .padding(.all, .zero)
}
