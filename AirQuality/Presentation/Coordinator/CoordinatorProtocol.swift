//
//  CoordinatorProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI

protocol CoordinatorProtocol: ObservableObject {
    associatedtype NavigationComponentType: Identifiable, Hashable
    associatedtype StartViewType: View
    associatedtype CreateViewType: View
    
    var fullScreenCover: NavigationComponentType? { get set }
    
    @ViewBuilder
    @MainActor
    func startView() -> StartViewType
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponentType) -> CreateViewType
}

extension CoordinatorProtocol {
    var fullScreenCover: NavigationComponentType? {
        get { nil }
        set { } // swiftlint:disable:this unused_setter_value
    }
}
