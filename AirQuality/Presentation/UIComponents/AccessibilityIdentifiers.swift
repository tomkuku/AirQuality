//
//  AccessibilityIdentifiers.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 19/11/2024.
//

import Foundation
import SwiftUI

struct AccessibilityIdentifiers {
    struct ObservedStationsListView {
        let addObservedStationsButton = ""
        let noObservedStations = ""
        let stationsList = ""
    }
    
    struct ProvincesListView {
        let provindesList = ""
        let provindesListRow = ""
    }
    
    struct ProvincesListRowView {
        let provinceName = ""
        let numberOfStations = ""
    }
    
    struct AllStationsListView {
        let stationsList = ""
    }
    
    struct AllStationsListProvinceStationsRowView {
        let street = ""
        let cityName = ""
        let isObserved = ""
        let isNotObserved = ""
    }
    
    struct AddObservedStationContainerView {
        let tabViewList = ""
        let tabViewMap = ""
    }
    
    struct BottomSheet {
        let grabber = ""
    }
    
    struct AddObservedStationMapView {
        let findTheNearestStationButton = ""
    }
    
    struct StationMapAnnotationView {
        let annotation = ""
        let street = ""
        let cityName = ""
        let province = ""
        let addObservedStationButton = ""
    }
    
    struct ParamsView {
        let params = ""
    }
    
    struct SelectedStationView {
        let sensorsList = ""
    }
    
    init() {}
    
    static let shared = AccessibilityIdentifiers()
    
    let doneToolbarButton = ""
    
    let observedStationsListView = ObservedStationsListView()
    let provincesListView = ProvincesListView()
    let provincesListRowView = ProvincesListRowView()
    let allStationsListView = AllStationsListView()
    let allStationsListProvinceStationsRowView = AllStationsListProvinceStationsRowView()
    let addObservedStationContainerView = AddObservedStationContainerView()
    let bottomSheet = BottomSheet()
    let addObservedStationMapView = AddObservedStationMapView()
    let stationMapAnnotationView = StationMapAnnotationView()
    let paramsView = ParamsView()
    let selectedStationView = SelectedStationView()
}

typealias AccessibilityIdentifierType = KeyPath<AccessibilityIdentifiers, String>

struct AccessibilityIdentifier: ViewModifier {
    private let identifier: String
    
    init(keyPath: AccessibilityIdentifierType) {
        self.identifier = String(describing: keyPath)
    }
    
    func body(content: Content) -> some View {
        content.accessibilityIdentifier(identifier)
    }
}

extension View {
    func accessibilityIdentifier(_ keyPath: AccessibilityIdentifierType) -> some View {
        self.modifier(AccessibilityIdentifier(keyPath: keyPath))
    }
}
