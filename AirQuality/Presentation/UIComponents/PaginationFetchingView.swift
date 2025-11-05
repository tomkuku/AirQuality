//
//  PaginationFetchingView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/11/2025.
//

import SwiftUI
import Lottie

enum PaginationFetchingState: Equatable {
    case readyToFetchNextPage
    case noMorePages
    case fetchingTheFirstPage
    case fetchingNextPage
    case refreshing
}

struct PaginationFetchingView<ViewModel, ItemView>: View where ViewModel: PaginationViewModelProtocol, ItemView: View {
    
    var body: some View {
        LazyVStack {
            ForEach(viewModel.items) { item in
                content(item)
            }
            
            switch viewModel.state {
            case .readyToFetchNextPage:
                Rectangle()
                    .foregroundStyle(.clear)
                    .onAppear {
                        Task {
                            await viewModel.fetchNextPage()
                        }
                    }
            case .fetchingNextPage:
                HStack {
                    Spacer()
                    
                    LottieView(animation: .named("LottieLoadingAnimation"))
                        .playing(loopMode: .loop)
                        .frame(width: 46, height: 46)
                        .padding(.top, 4)
                    
                    Spacer()
                }
                .frame(height: 60)
            
            case .fetchingTheFirstPage, .refreshing, .noMorePages:
                EmptyView()
            }
        }
    }
    
    private let content: (ViewModel.Item) -> ItemView
    @ObservedObject private var viewModel: ViewModel
    
    init(
        viewModel: ViewModel,
        @ViewBuilder content: @escaping (ViewModel.Item) -> ItemView
    ) {
        self.viewModel = viewModel
        self.content = content
    }
}

@MainActor
protocol PaginationViewModelProtocol: BaseViewModel {
    associatedtype UseCase: PaginationFetchingUseCaseProtocol
    associatedtype Item: Identifiable, Equatable
    
    var useCase: UseCase { get }
    var state: PaginationFetchingState { get set }
    var items: [Item] { get set }
    
    func fetchTheFirstPage()
    func pageDidFetch(_ page: [UseCase.DomainModel], areMorePages: Bool) async
}

extension PaginationViewModelProtocol {
    func refresh() {
        Task { [weak self] in
            do {
                self?.state = .refreshing
                try await self?.useCase.refresh()
            } catch {
                Logger.error("Refreshing archival measurements failed with error: \(error)")
                self?.errorSubject.send(error)
            }
        }
    }
    
    func fetchNextPage() async {
        do {
            state = .fetchingNextPage
            try await useCase.fetchNextPage()
        } catch {
            Logger.error("Fetching the next page of archival measurements failed with error: \(error)")
            errorSubject.send(error)
        }
    }
    
    func setupStream() {
        Task { [weak self] in
            guard let self else { return }
            
            for await value in await self.useCase.getStream() {
                await self.pageDidFetch(value.pageContent, areMorePages: value.areMorePages)
                
                self.state = value.areMorePages ? .readyToFetchNextPage : .noMorePages
            }
        }
    }
}
