//
//  PaginationFetchingView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/11/2025.
//

import SwiftUI
import Lottie

enum PaginationFetchingState: Equatable {
    case fetchingNextPage
    case none
    case fetchingTheFirstPage
    case refreshing
}

struct PaginationFetchingView<ViewModel, ItemView>: View where ViewModel: PaginationViewModelProtocol, ItemView: View {
    
    var body: some View {
        LazyVStack {
            ForEach(viewModel.items) { item in
                content(item)
            }
            
            switch viewModel.state {
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
            case .none:
                Rectangle()
                    .foregroundStyle(.clear)
                    .onAppear {
                        Task {
                            await viewModel.fetchNextPage()
                        }
                    }
            case .fetchingTheFirstPage, .refreshing:
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
    
    func pageDidFetch(page: [UseCase.DomainModel]) async
    func fetchingTheFirstPage()
}

extension PaginationViewModelProtocol {
    func refresh() {
        Task { [weak self] in
            print("refreshing")
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
        print("fetchNextPage")
        do {
            state = .fetchingNextPage
            try await useCase.fetchNextPage()
        } catch {
            Logger.error("Fetching the next page of archival measurements failed with error: \(error)")
            errorSubject.send(error)
        }
    }
    
    func fetchingTheFirstPage() {
        Task {
            print("fetchingTheFirstPage")
            do {
                state = .fetchingTheFirstPage
                try await useCase.fetchNextPage()
            } catch {
                Logger.error("Fetching the first page of archival measurements failed with error: \(error)")
                errorSubject.send(error)
            }
        }
    }
    
    func setupStream() {
        print("setupStream")
        Task { [weak self] in
            guard let self else { return }
            
            for await value in await self.useCase.getStream() {
                await self.pageDidFetch(page: value)
                self.state = .none
            }
        }
    }
}
