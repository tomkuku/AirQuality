//
//  ParamDescriptionView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/08/2025.
//

import SwiftUI

struct ParamDescriptionView: View {
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedParam) {
                ForEach(viewModel.elements) { element in
                    Text(element.param.formula).tag(element)
                }
            }
            .pickerStyle(.palette)
            
            ScrollView {
                ForEach(selectedParam.descriptions) { description in
                    VStack(spacing: 2) {
                        HStack {
                            Text(description.title)
                                .font(.system(size: 20, weight: .medium))
                            
                            Spacer()
                        }
                        
                        Text(description.description)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Color.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    // MARK: Private properties
    
    @State private var selectedParam: ParamDescriptionModel.ParamInfo
    @StateObject private var viewModel: ParamDescriptionViewModel
    
    init(viewModel: @autoclosure @escaping () -> ParamDescriptionViewModel) {
        let vm = viewModel()
        
        self._viewModel = StateObject(wrappedValue: vm)
        
        selectedParam = vm.elements[5]
    }
}

#Preview {
    let viewModel = ParamDescriptionViewModel()
    
    NavigationStack {
        ParamDescriptionView(viewModel: viewModel)
            .navigationTitle("Opis")
            .navigationBarTitleDisplayMode(.inline)
    }
}
