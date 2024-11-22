//
//  AccessibilityIdentifiers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 19/11/2024.
//

import Foundation

enum AccessibilityIdentifiers: String {
    case doneToolbarButton
    
    enum ObservedStationsListView: String {
        case addObservedStationsButton
        case noObservedStations
        case stationsList
    }
    
    enum AllStationsListProvindesView: String {
        case provindesList
    }
    
    enum AllStationsListProvindesRowView: String {
        case provinceName
        case numberOfStations
    }
    
    enum AllStationsListProvinceStationsView: String {
        case stationsList
    }
    
    enum AllStationsListProvinceStationsRowView: String {
        case street
        case cityName
        case isObserved
        case isNotObserved
    }
    
    enum AddObservedStationContainerView: String {
        case tabViewList
        case tabViewMap
    }
    
    enum BottomSheet: String {
        case grabber
    }
    
    enum AddObservedStationMapView: String {
        case findTheNearestStationButton
    }
    
    enum StationMapAnnotationView: String {
        case annotation
        case street
        case cityName
        case province
        case addObservedStationButton
    }
    
    enum ParamsView: String {
        case params
    }
    
    enum SelectedStationView: String {
        case sensorsList
    }
}
