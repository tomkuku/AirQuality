//
//  AlertView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import SwiftUI

struct AlertView: View {
    @StateObject private var viewModel: AlertViewModel
    
    var body: some View {
        if let alert = viewModel.alerts.first {
            Rectangle()
                .background(.clear)
                .foregroundStyle(.clear)
                .frame(width: .zero, height: .zero)
                .padding(.all, .zero)
                .alert(alert.title, isPresented: $viewModel.isAnyAlertPresented) {
                    Group {
                        ForEach(0..<alert.buttons.count, id: \.self) { index in
                            let button = alert.buttons[index]
                            
                            Button(role: button.role) {
                                button.action?()
                            } label: {
                                Text(button.title)
                            }
                        }
                    }
                    .onChange(of: viewModel.isAnyAlertPresented) { newValue in
                        if !newValue {
                            alert.dismissAction?()
                        }
                    }
                } message: {
                    if let message = alert.message {
                        Text(message)
                    } else {
                        EmptyView()
                    }
                }
        } else {
            EmptyView()
        }
    }
    
    init(viewModel: @autoclosure @escaping () -> AlertViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

import Combine

#Preview {
    // swiftlint:disable:next private_subject
    let publisher = PassthroughSubject<AlertModel, Never>()
    
    let viewModel = AlertViewModel(publisher)
    
    let alert = AlertModel(
        title: "Title",
        message: "Message",
        buttons: [
            .init(title: "Button 1", role: .cancel),
            .init(title: "Button 2", role: .destructive),
            .init(title: "Button 3")
        ], dismissAction: {
            print("Dismiss")
        })
    
    publisher.send(alert)
    
    return AlertView(viewModel: viewModel)
}
