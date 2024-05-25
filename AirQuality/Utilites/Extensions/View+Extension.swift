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
