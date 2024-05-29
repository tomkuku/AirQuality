//
//  ToastView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import SwiftUI
import Combine

struct ToastView: View {
    @ObservedObject private var viewModel: ToastsViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                ForEach(viewModel.toasts) { toast in
                    HStack {
                        Text(toast.body)
                            .foregroundStyle(Color.white)
                            .padding(.leading, 16)
                            .padding(.vertical, 16)
                        
                        Spacer()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(.black.opacity(0.8))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(Color.gray, lineWidth: 2)
                    }
                    .opacity(isToastPresnted(toast) ? 1 : 0)
                    .frame(height: isToastPresnted(toast) ? nil : 0)
                    .onAppear {
                        if !isToastPresnted(toast) {
                            withAnimation(.easeOut(duration: 0.4)) {
                                viewModel.presentedToasts.append(toast)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    init(toastsViewModel: @autoclosure @escaping () -> ToastsViewModel) {
        self._viewModel = ObservedObject(wrappedValue: toastsViewModel())
    }
    
    private func isToastPresnted(_ toast: Toast) -> Bool {
        viewModel.presentedToasts.contains(toast)
    }
}

#Preview {
    let publisher = PassthroughSubject<Toast, Never>()
    
    @StateObject var toastsViewModel = ToastsViewModel(publisher)
    
    Task {
        for i in 0..<Int.max {
            try? await Task.sleep(nanoseconds: UInt64(i) * 250_000_000)
            
            publisher.send(Toast(body: "\(i) Toast body text"))
        }
    }
    
    return ToastView(toastsViewModel: toastsViewModel)
}
