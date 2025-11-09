//
//  SensorArchivalMeasurementsFiltersView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/11/2025.
//

import SwiftUI

struct SensorArchivalMeasurementsFiltersView: View {
    
    // MARK: Body
    
    var body: some View {
        VStack {
            List {
                Section {
                    DatePicker("Date from", selection: $viewModel.dateFrom, in: ...Date(), displayedComponents: .date)
                    
                    DatePicker("Date to", selection: $viewModel.dateTo, in: ...Date(), displayedComponents: .date)
                } header: {
                    Text("Filters")
                } footer: {
                    if let dateError = viewModel.errors.datesError {
                        Text(dateError.localizedDescription)
                            .foregroundStyle(.red)
                    } else {
                        EmptyView()
                    }
                }
                
                Section {
                    HStack {
                        Text("Date")
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.dateSorting) {
                            ForEach(SensorArchivalMeasurementsListOptions.Sorting.Date.allCases) { sort in
                                Text(sort.localizedLongTitle).tag(sort)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Sorts")
                }
            }
            .listStyle(.insetGrouped)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    
                    Text("Apply")
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .frame(height: 40)
            .background(viewModel.isValid ? .blue : .gray.opacity(0.7))
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .padding(.horizontal, 16)
            .disabled(!viewModel.isValid)
        }
        .navigationTitle("Options")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    viewModel.clearFilters()
                }
            }
        }
    }
    
    // MARK: Private properties
    
    @StateObject private var viewModel: SensorArchivalMeasurementsFiltersViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Lifecycle
    
    init(viewModel: @autoclosure @escaping () -> SensorArchivalMeasurementsFiltersViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

// MARK: Preview

#Preview {
    let options = SensorArchivalMeasurementsListOptions(
        filters: .init(dateFrom: Date(), dateTo: Date()),
        sorting: .init(date: .descending)
    )
    let viewModel = SensorArchivalMeasurementsFiltersViewModel(options: options, callback: { _ in })
    
    NavigationStack {
        SensorArchivalMeasurementsFiltersView(viewModel: viewModel)
    }
}
