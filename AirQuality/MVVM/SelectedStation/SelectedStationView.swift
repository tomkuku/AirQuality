//
//  SelectedStationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI

struct SelectedStationView: View {
    @StateObject private var viewModel: SelectedStationViewModel
    
    var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.sensors) { sensor in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sensor.name)
                                
                                Text(sensor.formula)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                        }
                        .cornerRadius(10)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .task {
                await viewModel.fetchSensorsForStation()
            }
            .navigationTitle(viewModel.fomattedStationAddress)
    }
    
    init(viewModel: SelectedStationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    let station = Station(id: 11,
                          name: "",
                          latitude: 1,
                          longitude: 1,
                          cityName: "Kraków",
                          commune: "Kraków",
                          province: "Małopolska",
                          street: "al. Krasińskiego 1")
    
    struct GetSensorsUseCasePreviewMock: GetSensorsUseCaseProtocol {
        func getSensors(for stationId: Int) async throws -> [Sensor] {
            [
                Sensor(
                    id: 11,
                    name: "Pył zawieszony PM10",
                    formula: "PM10",
                    code: "PM10"
                ),
                Sensor(
                    id: 12,
                    name: "Benzen",
                    formula: "C6H6",
                    code: "C6H6"
                )
            ]
        }
    }
    
    let viewModel = SelectedStationViewModel(
        station: station,
        getSensorsUseCase: GetSensorsUseCasePreviewMock()
    )
    
    return SelectedStationView(viewModel: viewModel)
}
