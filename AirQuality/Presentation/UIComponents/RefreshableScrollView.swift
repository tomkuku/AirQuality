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
    
    private struct RefreshPorgress {
        var lottiePlaybackMode: LottiePlaybackMode = .paused(at: .progress(0))
        var refreshOpactiy: CGFloat = 0
        
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
                    .playbackMode(refreshPorgress.lottiePlaybackMode)
                    .frame(width: 46, height: 46)
                    .padding(.top, 4)
                    .opacity(refreshPorgress.refreshOpactiy)
                
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
    
    @State private var refreshPorgress: RefreshPorgress = .init()
    @State private var offsetY: CGFloat = 0
    
    @State private var isRefreshing = false
    @State private var isScrollDisabled = false
    
    @State private var lastScrollTranslationHeight: CGFloat = 0
    @State private var scrollViewFrameOriginY: CGFloat = 0
    
    private let onRefresh: @MainActor @Sendable () async -> ()
    private let contentView: () -> ContentView
    private let beginShowingRefreshControllYPosition: CGFloat
    private let endShowingRefreshControllYPosition: CGFloat
    private let animationFactor = 0.3
    private let offsetYWhenGestureEnds: CGFloat = 60
    private let accessibilityIdentifier: String
    
    // MARK: Init
    
    init(
        onRefresh: @MainActor @Sendable @escaping () async -> (),
        contentView: @escaping () -> ContentView,
        beginShowingRefreshControllYPosition: CGFloat = 100,
        endShowingRefreshControllYPosition: CGFloat = 330,
        accessibilityIdentifier: String = ""
    ) {
        self.onRefresh = onRefresh
        self.contentView = contentView
        self.beginShowingRefreshControllYPosition = beginShowingRefreshControllYPosition
        self.endShowingRefreshControllYPosition = endShowingRefreshControllYPosition
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    // MARK: Private methods
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.translation.height >= 0 else { return }
                
                let scroll = value.translation.height
                
                if scroll >= beginShowingRefreshControllYPosition {
                    let progress = (scroll - beginShowingRefreshControllYPosition) / endShowingRefreshControllYPosition
                    
                    var refreshPorgress = self.refreshPorgress
                    
                    if progress > 1 {
                        refreshPorgress.setLottiePlaybackModeToPlayingInfinity()
                        refreshPorgress.refreshOpactiy = 1
                    } else {
                        let animationProgress = progress * animationFactor
                        refreshPorgress.setLottiePlaybackModeToPaused(atProgress: animationProgress)
                        refreshPorgress.refreshOpactiy = progress
                    }
                    
                    self.refreshPorgress = refreshPorgress
                }
            }
            .onEnded { value in
                let scroll = value.translation.height
                
                if scroll >= endShowingRefreshControllYPosition {
                    withAnimation {
                        offsetY = offsetYWhenGestureEnds
                        isScrollDisabled = true
                        
                        var refreshPorgress = self.refreshPorgress
                        refreshPorgress.setLottiePlaybackModeToPlayingInfinity()
                        refreshPorgress.refreshOpactiy = 1
                        self.refreshPorgress = refreshPorgress
                    } completion: {
                        Task { @MainActor in
                            await onRefresh()
                            
                            endRefreshing()
                        }
                    }
                } else {
                    var refreshPorgress = self.refreshPorgress
                    refreshPorgress.setLottiePlaybackModeToPlayOnceFromCurrentProgress()
                    refreshPorgress.refreshOpactiy = 0.0
                    self.refreshPorgress = refreshPorgress
                }
            }
    }
    
    private func endRefreshing() {
        withAnimation(.easeOut) {
            self.offsetY = 0
            self.isScrollDisabled = false
            
            var refreshPorgress = self.refreshPorgress
            refreshPorgress.refreshOpactiy = 0
            self.refreshPorgress = refreshPorgress
        } completion: {
            var refreshPorgress = self.refreshPorgress
            refreshPorgress.setLottiePlaybackModeToPaused(atProgress: 0)
            self.refreshPorgress = refreshPorgress
        }
    }
}
