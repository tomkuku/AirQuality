//
//  BottomSheet.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/06/2024.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @State private var sheetOffset: CGFloat
    @State private var isExpanded: Bool = false
    @GestureState private var dragOffset: CGFloat = 0
    
    private let minHeight: CGFloat
    private let maxHeight: CGFloat
    private let content: Content

    var grabberImage: Image {
        if isExpanded {
            Image.chevronCompactDown
        } else {
            Image.chevronCompactUp
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 1)) {
                        if isExpanded {
                            sheetOffset = minHeight
                            isExpanded = false
                        } else {
                            sheetOffset = maxHeight
                            isExpanded = true
                        }
                    }
                } label: {
                    grabberImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tint(.secondary)
                        .frame(width: 30, height: 10)
                        .padding(.top, 16)
                        .foregroundStyle(.gray)
                }
                .background(.clear)
                
                content
                    .background(Color.Background.secondary)
                
                Spacer()
            }
            .frame(height: geometry.size.height)
            .background(Color.Background.secondary)
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            .shadow(radius: 10)
            .offset(y: geometry.size.height - sheetOffset)
            .gesture(dragGesture)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onChanged { value in
                let newHeight: CGFloat
                
                if isExpanded {
                    newHeight = maxHeight - value.translation.height
                } else {
                    newHeight = -value.translation.height
                }
                
                if abs(newHeight) >= minHeight && newHeight <= maxHeight {
                    sheetOffset = abs(newHeight)
                }
            }
            .onEnded { _ in
                let midHeight = (minHeight + maxHeight) / 2
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 1)) {
                    if sheetOffset < midHeight {
                        sheetOffset = minHeight
                        isExpanded = false
                    } else {
                        sheetOffset = maxHeight
                        isExpanded = true
                    }
                }
            }
    }

    init(
        minHeight: CGFloat,
        maxHeight: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.sheetOffset = minHeight
    }
}
