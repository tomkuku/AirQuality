//
//  ContentView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 24/04/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
//            let useCase = GetStationsUseCase()
            
            Task {
//                do {
//                    let stations = try await useCase.getAllStations()
//                    print(stations)
//                } catch {
//                    print(error.localizedDescription)
//                }
            }
        }
    }
}

#Preview {
    ContentView()
}
