//
//  AnimatingHeight.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/07/2024.
//

import SwiftUI

struct AnimatingHeight: AnimatableModifier {
    private var height: CGFloat
    
    nonisolated var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    
    init(height: CGFloat) {
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content.frame(maxHeight: height)
    }
}
