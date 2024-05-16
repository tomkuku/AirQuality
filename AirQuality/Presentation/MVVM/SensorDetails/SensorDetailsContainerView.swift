//
//  SensorDetailsContainerView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 16/05/2024.
//

import SwiftUI

enum SensorDetailsContainerSubview: CaseIterable {
    case paramDescription
    case measurementsList
    case measurementsChart
    
    var text: String {
        switch self {
        case .paramDescription:
            "Opis parametru"
        case .measurementsList:
            "Lista pomiarów"
        case .measurementsChart:
            "Wykres pomiarów"
        }
    }
}

struct SensorDetailsContainerView: View {
    @State private var selectedElementId: Int = 0
    
    var body: some View {
        Text("Cos tam")
        
        createNavigationMenuView()
            .frame(height: 40)
        
        GeometryReader(content: { geometry in
            ScrollViewReader(content: { scrollViewProxy in
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .center, spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            ZStack {
                                StationsListView()
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(color(for: index))
                        }
                    }
                }
                .scrollDisabled(true)
                .onChange(of: selectedElementId) { _ in
                    withAnimation(.easeOut) {
                        scrollViewProxy.scrollTo(selectedElementId)
                    }
                }
            })
        })
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func createNavigationMenuView() -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<SensorDetailsContainerSubview.allCases.count, id: \.self) { index in
                        let element = SensorDetailsContainerSubview.allCases[index]
                        
                        Text("\(element.text)")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundStyle(index == selectedElementId ? .white : .black)
                            .background {
                                if index == selectedElementId {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.gray)
                                } else {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray, lineWidth: 3)
                                }
                            }
                            .gesture(TapGesture().onEnded {
                                withAnimation {
                                    scrollViewProxy.scrollTo(index)
                                    selectedElementId = index
                                }
                            })
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .scrollIndicators(.never, axes: .horizontal)
    }
    
    private func color(for index: Int) -> Color {
        switch index {
        case 0:
            Color.blue
        case 1:
            Color.green
        case 2:
            Color.red
        default:
            Color.black
        }
    }
}
#Preview {
    SensorDetailsContainerView()
}
