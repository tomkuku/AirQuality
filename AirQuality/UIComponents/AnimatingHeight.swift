//
//  AnimatingHeight.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/07/2024.
//

import Foundation
import SwiftUI

struct AnimatingHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
