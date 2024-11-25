//
//  Params.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/07/2024.
//

import SwiftUI

struct ParamsView: View {
    
    private typealias L10n = Localizable.AddObservedStationMapView.AnnotationView
    
    // MARK: Properties
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(L10n.measuredParametres)
                    .foregroundStyle(Color.Text.secondary)
                    .padding(.bottom, 8)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(alignment: .center)
            } else if let params = viewModel.params {
                FlexibleView(
                    data: params,
                    spacing: 10,
                    alignment: .leading
                ) { param in
                    Text(param.formula)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 0)
                        .foregroundStyle(.white)
                        .fixedSize()
                        .frame(height: 16)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(Color.Standard.grey)
                        }
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.ParamsView.params.rawValue)
            } else {
                Text(L10n.noParams)
            }
        }
        .taskOnFirstAppear {
            viewModel.fetchParamsMeasuredByStation()
        }
    }
    
    // MARK: Private properties
    
    @StateObject private var viewModel: ParamsViewModel
    
    // MARK: Lifecycle
    
    init(station: Station) {
        let viewModel = ParamsViewModel(station: station)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    GetStationSensorsParamsUseCasePreviewDummy.getParamsResult = [.c6h6, .pm10, .pm25, .so2, .co, .no2, .o3]
    
    @State var heigth: CGFloat = .zero
    
    return VStack {
        Rectangle()
            .foregroundStyle(.red)
        ParamsView(station: .previewDummy())
        Rectangle()
             .foregroundStyle(.blue)
    }
}
