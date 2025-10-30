//
//  RefreshableScrollView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 30/01/2025.
//

import SwiftUI
import Lottie

struct RefreshableScrollView<ContentView>: View where ContentView: View {
    
    // MARK: - Type
    
    private struct RefreshProgress {
        var lottiePlaybackMode: LottiePlaybackMode = .paused(at: .progress(0))
        var refreshOpacity: CGFloat = 0
        
        mutating func setLottiePlaybackModeToPlayingInfinity() {
            lottiePlaybackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .repeat(.greatestFiniteMagnitude)))
        }
        
        mutating func setLottiePlaybackModeToPlayOnceFromCurrentProgress() {
            lottiePlaybackMode = .playing(.fromProgress(nil, toProgress: 1, loopMode: .playOnce))
        }
        
        mutating func setLottiePlaybackModeToPaused(atProgress: AnimationProgressTime) {
            lottiePlaybackMode = .paused(at: .progress(atProgress))
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack {
                LottieView(animation: .named("LottieLoadingAnimation"))
                    .playbackMode(refreshProgress.lottiePlaybackMode)
                    .frame(width: 46, height: 46)
                    .padding(.top, 4)
                    .opacity(refreshProgress.refreshOpacity)
                
                Spacer()
            }
            .zIndex(2)
            
            ScrollView {
                LazyVStack {
                    contentView()
                }
                .offset(y: offsetY)
            }
            .scrollDisabled(isScrollDisabled)
            .accessibilityIdentifier(accessibilityIdentifier)
            .simultaneousGesture(
                createDragGesture()
            )
            .zIndex(1)
        }
    }
    
    // MARK: Private properties
    
    @State private var refreshProgress: RefreshProgress = .init()
    @State private var offsetY: CGFloat = 0
    
    @State private var isRefreshing = false
    @State private var isScrollDisabled = false
    
    @State private var lastScrollTranslationHeight: CGFloat = 0
    @State private var scrollViewFrameOriginY: CGFloat = 0
    
    private let onRefresh: @MainActor @Sendable () async -> ()
    private let contentView: () -> ContentView
    private let beginShowingRefreshControlYPosition: CGFloat
    private let endShowingRefreshControlYPosition: CGFloat
    private let animationFactor = 0.3
    private let offsetYWhenGestureEnds: CGFloat = 60
    private let accessibilityIdentifier: AccessibilityIdentifierType
    
    // MARK: Init
    
    init(
        onRefresh: @MainActor @Sendable @escaping () async -> (),
        contentView: @escaping () -> ContentView,
        beginShowingRefreshControlYPosition: CGFloat = 100,
        endShowingRefreshControlYPosition: CGFloat = 330,
        accessibilityIdentifier: AccessibilityIdentifierType
    ) {
        self.onRefresh = onRefresh
        self.contentView = contentView
        self.beginShowingRefreshControlYPosition = beginShowingRefreshControlYPosition
        self.endShowingRefreshControlYPosition = endShowingRefreshControlYPosition
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    // MARK: Private methods
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.translation.height >= 0 else { return }
                
                let scroll = value.translation.height
                
                if scroll >= beginShowingRefreshControlYPosition {
                    let progress = (scroll - beginShowingRefreshControlYPosition) / endShowingRefreshControlYPosition
                    
                    var refreshProgress = self.refreshProgress
                    
                    if progress > 1 {
                        refreshProgress.setLottiePlaybackModeToPlayingInfinity()
                        refreshProgress.refreshOpacity = 1
                    } else {
                        let animationProgress = progress * animationFactor
                        refreshProgress.setLottiePlaybackModeToPaused(atProgress: animationProgress)
                        refreshProgress.refreshOpacity = progress
                    }
                    
                    self.refreshProgress = refreshProgress
                }
            }
            .onEnded { value in
                let scroll = value.translation.height
                
                if scroll >= endShowingRefreshControlYPosition {
                    withAnimation {
                        offsetY = offsetYWhenGestureEnds
                        isScrollDisabled = true
                        
                        var refreshProgress = self.refreshProgress
                        refreshProgress.setLottiePlaybackModeToPlayingInfinity()
                        refreshProgress.refreshOpacity = 1
                        self.refreshProgress = refreshProgress
                    } completion: {
                        Task { @MainActor in
                            await onRefresh()
                            
                            endRefreshing()
                        }
                    }
                } else {
                    var refreshProgress = self.refreshProgress
                    refreshProgress.setLottiePlaybackModeToPlayOnceFromCurrentProgress()
                    refreshProgress.refreshOpacity = 0.0
                    self.refreshProgress = refreshProgress
                }
            }
    }
    
    private func endRefreshing() {
        withAnimation(.easeOut) {
            self.offsetY = 0
            self.isScrollDisabled = false
            
            var refreshProgress = self.refreshProgress
            refreshProgress.refreshOpacity = 0
            self.refreshProgress = refreshProgress
        } completion: {
            var refreshProgress = self.refreshProgress
            refreshProgress.setLottiePlaybackModeToPaused(atProgress: 0)
            self.refreshProgress = refreshProgress
        }
    }
}
#Preview {
    let stations: [Station] = [
        .previewDummy(id: 1, province: "Małopolskie"),
        .previewDummy(id: 2, province: "zachodniopomorskie"),
        .previewDummy(id: 3, province: "Mazowieckie"),
        .previewDummy(id: 4, province: "Opolskie")
    ]
    
    NavigationStack {
        RefreshableScrollView(
            onRefresh: {},
            contentView: {
                ForEach(stations) { station in
                    HStack {
                        Text(station.cityName)
                        Spacer()
                        Text("\(station.id)")
                    }
                    .frame(height: 40)
                }
            }, accessibilityIdentifier: \.provincesListView.provindesList)
    }
}
