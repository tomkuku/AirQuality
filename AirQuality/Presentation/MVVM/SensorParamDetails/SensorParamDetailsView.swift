//
//  SensorParamDetailsView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import SwiftUI

struct SensorParamDetailsView: View {
    @StateObject private var viewModel: SensorParamDetailsViewModel
    
    var body: some View {
        ScrollView {
            Text(viewModel.paramDescription)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> SensorParamDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}
