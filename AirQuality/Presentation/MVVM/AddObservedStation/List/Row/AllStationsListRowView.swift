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
        ZStack {
            rowContent
            paramsView
        }
        .padding(.vertical, 8)
        .modifier(AnimatingHeight(height: isExpanded ? 160 : 80))
    }
    
    private var rowContent: some View {
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
            
            Spacer()
        }
    }
    
    private var paramsView: some View {
        VStack {
            Spacer()
            
            if isExpanded {
                ParamsView(station: station)
                    .padding(.leading, 48)
                    .transition(.opacity)
                    .gesture(DragGesture().exclusively(before: TapGesture()))
            }
        }
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
    
    GetStationSensorsParamsUseCasePreviewDummy.getParamsResult = [.c6h6, .pm10, .pm25, .so2, .co, .no2, .o3]
    
    return VStack {
        Rectangle()
            .foregroundStyle(.blue)
        
        AllStationsListRowView(station: station, isStationObserved: true)
        
        Rectangle()
            .foregroundStyle(.red)
    }
    .padding(.all, .zero)
}
