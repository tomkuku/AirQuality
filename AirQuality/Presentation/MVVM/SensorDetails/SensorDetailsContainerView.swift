//
//  SensorDetailsContainerView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 16/05/2024.
//

import SwiftUI

enum SensorDetailsContainerSubview: CaseIterable {
    case paramDescription
    case measurementsList
    case measurementsChart
    
    var text: String {
        switch self {
        case .paramDescription:
            "Opis parametru"
        case .measurementsList:
            "Lista pomiarów"
        case .measurementsChart:
            "Wykres pomiarów"
        }
    }
}

struct SensorDetailsContainerView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @State private var selectedElementId: Int = 0
    
    private let sensor: Sensor
    
    var body: some View {
        NavigationStack {
            createNavigationMenuView()
                .frame(height: 40)
            
            GeometryReader(content: { geometry in
                ScrollViewReader(content: { scrollViewProxy in
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .center, spacing: 0) {
                            ForEach(0..<3, id: \.self) { index in
                                ZStack {
                                    if index == 1 {
                                        let viewModel = SensorArchivalMeasurementsListViewModel(sensor: sensor)
                                        SensorArchivalMeasurementsListView(viewModel: viewModel)
                                    } else if index == 0 {
                                        let viewModel = SensorParamDetailsViewModel(sensor: sensor)
                                        SensorParamDetailsView(viewModel: viewModel)
                                    } else {
                                        let viewModel = SensorArchivalMeasurementsListViewModel(sensor: sensor)
                                        SensorArchivalMeasurementsChartView(viewModel: viewModel)
                                    }
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                    }
                    .scrollDisabled(true)
                    .onChange(of: selectedElementId) {
                        withAnimation(.easeOut) {
                            scrollViewProxy.scrollTo(selectedElementId)
                        }
                    }
                })
            })
            .toolbar {
                Button("Close") {
                    appCoordinator.dismiss()
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    init(sensor: Sensor) {
        self.sensor = sensor
    }
    
    private func createNavigationMenuView() -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<SensorDetailsContainerSubview.allCases.count, id: \.self) { index in
                        let element = SensorDetailsContainerSubview.allCases[index]
                        
                        Text("\(element.text)")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundStyle(index == selectedElementId ? .white : .black)
                            .background {
                                if index == selectedElementId {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.gray)
                                } else {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray, lineWidth: 3)
                                }
                            }
                            .gesture(TapGesture().onEnded {
                                withAnimation {
                                    scrollViewProxy.scrollTo(index)
                                    selectedElementId = index
                                }
                            })
                            .accessibilityAddTraits(.isButton)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .scrollIndicators(.never, axes: .horizontal)
    }
    
    private func color(for index: Int) -> Color {
        switch index {
        case 0:
            Color.blue
        case 1:
            Color.green
        case 2:
            Color.red
        default:
            Color.black
        }
    }
}
