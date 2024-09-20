//
//  ToastsView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import SwiftUI
import Combine

struct ToastsView: View {
    @ObservedObject private var viewModel: ToastsViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                ForEach(viewModel.toasts) { toast in
                    ToastView(toast: toast, viewModel: viewModel)
                }
            }
            .animation(.smooth, value: viewModel.toasts)
        }
    }
    
    init(toastsViewModel: @autoclosure @escaping () -> ToastsViewModel) {
        self._viewModel = ObservedObject(wrappedValue: toastsViewModel())
    }
}

struct ToastView: View {
    @State private var isVisiable = false
    
    private let viewModel: ToastsViewModel
    private let toast: ToastModel
    
    var body: some View {
        HStack {
            Text(toast.body)
                .foregroundStyle(Color.white)
                .padding(.leading, 16)
                .padding(.vertical, 16)
            
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.black.opacity(0.9))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.gray, lineWidth: 2)
        }
        .opacity(isVisiable ? 1 : 0)
        .offset(y: getOffset())
        .scaleEffect(isVisiable ? 1.0 : 0.9)
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 13)) {
                isVisiable = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                withAnimation(.easeIn(duration: 0.3)) {
                    isVisiable = false
                } completion: {
                    viewModel.removeToast(toast)
                }
            }
        }
    }

    init(toast: ToastModel, viewModel: ToastsViewModel) {
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
    let subject = PassthroughSubject<ToastModel, Never>()
    
    @StateObject var toastsViewModel = ToastsViewModel(subject.eraseToAnyPublisher())
        
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        subject.send(ToastModel(body: "1 ToastModel body text"))
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        subject.send(ToastModel(body: "2 ToastModel body text"))
    }
    
    return VStack {
        ToastsView(toastsViewModel: toastsViewModel)
    }
}
