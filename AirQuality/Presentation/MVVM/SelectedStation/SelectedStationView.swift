//
//  SelectedStationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI

struct SelectedStationView: View {
    private typealias L10n = Localizable.SelectedStationView
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @StateObject private var viewModel: SelectedStationViewModel
    @State private var dataProviderAnimate = false
    
    var body: some View {
        BaseView(viewModel: viewModel, coordinator: appCoordinator) {
            if !viewModel.isLoading {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<viewModel.sensors.count, id: \.self) { index in
                            SelectedStationSensorRow(sensor: viewModel.sensors[index], index: index)
                        }
                        
                        dataProvider
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .refreshable {
                    /// Delay to avoid instacne switch between sensors list and loading indicator.
                    try? await Task.sleep(for: .milliseconds(600))
                    
                    viewModel.refresh()
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.SelectedStationView.sensorsList.rawValue)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                        .controlSize(.regular)
                    
                    Text(Localizable.SelectedStationView.isLoading)
                }
            }
        }
        .background(Color.Background.primary)
        .navigationTitle(viewModel.formattedStationAddress)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isLoading) { _, _ in
            dataProviderAnimate = false
        }
        .task {
            await viewModel.fetchSensorsForStation()
        }
    }
    
    private var dataProvider: some View {
        HStack {
            Text(L10n.dataProvider)
                .font(.system(size: 14))
                .foregroundStyle(Color.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .opacity(dataProviderAnimate ? 1 : 0)
        .onAppear {
            let delay = 0.2 * TimeInterval(viewModel.sensors.count)
            withAnimation(.linear(duration: 0.5).delay(delay)) {
                dataProviderAnimate = true
            }
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

#Preview {
    GetSensorsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, param: .pm10),
        .previewDummy(id: 2, param: .pm25),
        .previewDummy(id: 3, param: .c6h6),
        .previewDummy(id: 4, param: .co),
        .previewDummy(id: 5, param: .no2),
        .previewDummy(id: 6, param: .o3),
        .previewDummy(id: 7, param: .so2)
    ]
    
    let station = Station.previewDummy()
    let appCoordinator = AppCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {}),
        alertSubject: .init(),
        toastSubject: .init()
    )
    
    return NavigationStack {
        SelectedStationView(viewModel: .init(station: station))
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(appCoordinator)
    }
}

#Preview {
    GetSensorsUseCasePreviewDummy.fetchReturnValue = [
        .previewDummy(id: 1, param: .pm10),
        .previewDummy(id: 2, param: .pm25),
        .previewDummy(id: 3, param: .c6h6),
        .previewDummy(id: 4, param: .co),
        .previewDummy(id: 5, param: .no2),
        .previewDummy(id: 6, param: .o3),
        .previewDummy(id: 7, param: .so2)
    ]
    
    let station = Station.previewDummy()
    let appCoordinator = AppCoordinator(
        coordinatorNavigationType: .presentation(dismissHandler: {}),
        alertSubject: .init(),
        toastSubject: .init()
    )
    
    return NavigationStack {
        SelectedStationView(viewModel: .init(station: station))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .environmentObject(appCoordinator)
    }
}

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
