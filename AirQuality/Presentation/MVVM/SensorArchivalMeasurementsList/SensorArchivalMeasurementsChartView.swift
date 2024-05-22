//
//  SensorArchivalMeasurementsChartView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import SwiftUI
import Charts

struct SensorArchivalMeasurementsChartView: View {
    @StateObject private var viewModel: SensorArchivalMeasurementsListViewModel
    
    var body: some View {
        VStack {
            Chart {
                ForEach(0..<viewModel.rows.count, id: \.self) { index in
                    let row = viewModel.rows[index]
                    
                    LineMark(
                        x: .value(row.formattedDate, row.date),
                        y: .value(row.formattedValue, row.value)
                    )
                    .interpolationMethod(.catmullRom)
                }
                
                RuleMark(y: .value("", viewModel.sensor.param.quota))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10]))
                    .annotation(alignment: .trailing) {
                        Text(String(format: "%2.f", viewModel.sensor.param.quota))
                            .font(.subheadline)
                            .bold()
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .foregroundStyle(Color.white)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
            }
            .chartLegend(position: .top, alignment: .center) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    
                    Text("norma")
                        .foregroundStyle(.black)
                        .font(.system(size: 11, weight: .medium))
                }
                .background(Color.red)
            }
            .chartXAxis {
                AxisMarks(preset: .extended, position: .bottom, values: .automatic(desiredCount: 10)) { value in
                    if let date = value.as(Date.self) {
                        
                        AxisValueLabel {
                            VStack(alignment: .leading) {
                                Text(date, format: .dateTime.month().year())
                                    .scaledToFill()
                                    .rotationEffect(.degrees(45), anchor: .leading)
                            }
                            .position(y: 6)
                            .frame(height: 60)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 30)
        .padding(.bottom, 100)
        .taskOnFirstAppear {
            await viewModel.fetchArchivalMeasurements()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> SensorArchivalMeasurementsListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

struct SensorArchivalMeasurementsChartView_Previews: PreviewProvider {
    @ObservedObject private static var viewModel = SensorArchivalMeasurementsListViewModel.previewDummy
    
    static var previews: some View {
        SensorArchivalMeasurementsChartView(viewModel: viewModel)
    }
}
