//
//  StationMapAnnotationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 07/06/2024.
//

import Foundation
import MapKit
import SwiftUI

struct StationMapAnnotationView: MapContent {
    private typealias L10n = Localizable.AddObservedStationMapView.AnnotationView
    
    @State private var isSelected = false
    @State private var paramsGridHeight: CGFloat = 0
    
    @StateObject private var viewModel: AllStationStationViewModel
    
    var body: some MapContent {
        Annotation("", coordinate: stationAnnotation.coordinates, anchor: .bottom) {
            VStack {
                Image.mappin
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .onTapGesture {
                isSelected = true
            }
            .popover(isPresented: $isSelected,
                     attachmentAnchor: .point(.top),
                     arrowEdge: .bottom) {
                expandedStationPopover
                    .presentationCompactAdaptation(.popover)
                    .background(Color.Background.secondary)
            }
        }
    }
    
    private var expandedStationPopover: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading) {
                let station = stationAnnotation.station
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.station)
                        .foregroundStyle(Color.Text.secondary)
                        .padding(.bottom, 4)
                    
                    Group {
                        if let street = station.street {
                            Text(street)
                        }
                        Text(station.cityName)
                        Text(station.province)
                            .padding(.bottom, 8)
                    }
                }
                .frame(alignment: .leading)
                
                ParamsView(station: station)
                    .padding(.all, 0)
            }
            
            addObservedStationButton
        }
        .background(Color.Background.secondary)
        .padding(.all, 16)
        .frame(width: 250)
    }
    
    @ViewBuilder
    private var addObservedStationButton: some View {
        Button(action: {
            if stationAnnotation.isStationObserved {
                viewModel.deletedObservedStation(stationAnnotation.station)
            } else {
                viewModel.addObservedStation(stationAnnotation.station)
            }
        }, label: {
            let text: String = if stationAnnotation.isStationObserved {
                L10n.addObservedStation
            } else {
                L10n.deleteObservedStation
            }
            
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .frame(height: 36)
                .padding(.horizontal, 8)
        })
        .tint(.white)
        .controlSize(.small)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.blue)
        }
        .padding(.top, 8)
    }
    
    private let stationAnnotation: AddObservedStationMapModel.StationAnnotation
    
    init(
        stationAnnotation: AddObservedStationMapModel.StationAnnotation
    ) {
        self.stationAnnotation = stationAnnotation
        self._viewModel = StateObject(wrappedValue: AllStationStationViewModel(station: stationAnnotation.station))
    }
}

#Preview {
    FetchAllStationsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(latitude: 50.057678, longitude: 19.926189)
    ]
    
    GetStationSensorsParamsUseCasePreviewDummy.getParamsResult = [.c6h6, .pm10, .pm25, .so2, .co, .no2, .o3]
        
    @ObservedObject var coordinator = AddObservedStationMapCoordinator.previewDummy
    
    return AddObservedStationMapView()
        .environmentObject(coordinator)
        .preferredColorScheme(.dark)
}
