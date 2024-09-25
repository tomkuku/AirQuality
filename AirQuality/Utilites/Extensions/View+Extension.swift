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
    
    func doneToolbarButton(_ action: @escaping () -> ()) -> some View {
        modifier(DoneToolbarButton(action: action))
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

struct DoneToolbarButton: ViewModifier {
    private typealias L10n = Localizable.NavigationToolbar.DoneButton
    
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
