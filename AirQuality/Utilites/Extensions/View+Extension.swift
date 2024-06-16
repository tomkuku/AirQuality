//
//  View+Extensions.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import SwiftUI

extension View {
    func taskOnFirstAppear(_ action: @escaping () async -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
    
    func dimissToolbarButton(_ action: @escaping () -> ()) -> some View {
        modifier(DismissToolbarButton(action: action))
    }
}

struct FirstAppear: ViewModifier {
    let action: () async -> ()
    
    @State private var isFirstAppear = false
    
    func body(content: Content) -> some View {
        content.task {
            guard !isFirstAppear else { return }
            isFirstAppear = true
            await action()
        }
    }
    
    init(action: @escaping () async -> ()) {
        self.action = action
    }
}

struct DismissToolbarButton: ViewModifier {
    private typealias L10n = Localizable.NavigationToolbar.DismissButton
    
    private let action: () -> ()
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                Button(action: action, label: {
                    Text(L10n.title)
                })
            }
    }
    
    init(action: @escaping () -> ()) {
        self.action = action
    }
}
