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
                .allowsHitTesting(false)
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
                    .onChange(of: viewModel.isAnyAlertPresented) { _ in
                        if !viewModel.isAnyAlertPresented {
                            alert.dimissAction?()
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
    
    init(viewModel: AlertViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    let viewModel = AlertViewModel()
    viewModel.alerts.append(AlertModel(title: "Tytul", message: "wiadomosc", buttons: [
        .init(title: "Przycisk", role: .cancel),
        .init(title: "Przycisk 2", role: .destructive),
        .init(title: "Przycisk 3")
    ], dimissAction: {
        print("DOne")
    }))
    
    return AlertView(viewModel: viewModel)
}
