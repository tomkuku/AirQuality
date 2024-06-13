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
    
    @State private var isPopoverPresented = false
    
    @ObservedObject private var viewModel: AddObservedStationMapViewModel
    
    var body: some MapContent {
        Annotation(coordinate: stationAnnotation.coordinates) {
            VStack {
                let imageColor: Color = stationAnnotation.isStationObserved ? .blue : .red
                
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(imageColor)
            }
            .onTapGesture {
                isPopoverPresented = true
            }
            .popover(isPresented: $isPopoverPresented,
                     attachmentAnchor: .point(.top),
                     arrowEdge: .bottom) {
                VStack {
                    let station = stationAnnotation.station
                    
                    if let street = station.street {
                        Text(street)
                    }
                    
                    Text(station.cityName)
                    Text(station.province)
                        .padding(.bottom, 8)
                    
                    Button(action: {
                        if stationAnnotation.isStationObserved {
                            viewModel.deletedStationFromObservedList(station)
                        } else {
                            viewModel.addStationToObserved(station)
                        }
                    }, label: {
                        let text: String = if stationAnnotation.isStationObserved {
                            L10n.addObservedStation
                        } else {
                            L10n.deleteObservedStation
                        }
                        
                        Text(text)
                            .font(.system(size: 14, weight: .semibold))
                            .frame(height: 30)
                            .padding(.horizontal, 8)
                    })
                    .tint(.blue)
                    .controlSize(.small)
                    .buttonStyle(.borderedProminent)
                }
                .background(.white)
                .padding(.all, 16)
                .presentationCompactAdaptation(.popover)
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            }
        } label: {
            EmptyView()
                .frame(width: 30, height: 30)
        }
    }
    
    private let stationAnnotation: AddObservedStationMapModel.StationAnnotation
    
    init(
        stationAnnotation: AddObservedStationMapModel.StationAnnotation,
        viewModel: AddObservedStationMapViewModel
    ) {
        self.stationAnnotation = stationAnnotation
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
}

#Preview {
    GetStationsUseCasePreviewDummy.getStationsReturnValue = [
        .previewDummy(latitude: 50.057678, longitude: 19.926189)
    ]
    
    @ObservedObject var coordinator = AddObservedStationMapCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {})
    )
    
    return AddObservedStationMapView()
                .environmentObject(coordinator)
}
