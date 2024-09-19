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
                    ToastView2(toast: toast, viewModel: viewModel)
                }
            }
            .animation(.smooth, value: viewModel.toasts)
        }
    }
    
    init(toastsViewModel: @autoclosure @escaping () -> ToastsViewModel) {
        self._viewModel = ObservedObject(wrappedValue: toastsViewModel())
    }
    
    private func isToastPresnted(_ toast: Toast) -> Bool {
        viewModel.presentedToasts.contains(toast)
    }
}

struct ToastView2: View {
    private let toast: Toast
    
    @State private var isVisiable = false
    private let viewModel: ToastsViewModel
    
    var body: some View {
        HStack {
            Text(toast.body)
                .foregroundStyle(Color.white)
                .padding(.leading, 16)
                .padding(.vertical, 16)
            
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.black.opacity(0.9))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Color.gray, lineWidth: 2)
        }
        .opacity(isVisiable ? 1 : 0)
        .offset(y: getOffset())
        .scaleEffect(isVisiable ? 1.0 : 0.9)
        .onAppear {
            withAnimation(.linear(duration: 0.3)) {
                isVisiable = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                withAnimation(.linear(duration: 0.3)) {
                    isVisiable = false
                } completion: {
                    viewModel.removeToast(toast)
                }
            }
        }
    }

    init(toast: Toast, viewModel: ToastsViewModel) {
        self.toast = toast
        self.viewModel = viewModel
    }
    
    private func getOffset() -> CGFloat {
        if viewModel.toasts.count == 1 {
            if isVisiable {
                return 0 // show
            } else {
                return 100 // hide
            }
        } else {
            return 0
        }
    }
}

#Preview {
    // swiftlint:disable:next private_subject
    let subject = PassthroughSubject<Toast, Never>()
    
    @StateObject var toastsViewModel = ToastsViewModel(subject.eraseToAnyPublisher())
        
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        subject.send(Toast(body: "1 Toast body text"))
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        subject.send(Toast(body: "2 Toast body text"))
    }
    
    return VStack {
        ToastView(toastsViewModel: toastsViewModel)
    }
    .padding(.horizontal, 16)
}
