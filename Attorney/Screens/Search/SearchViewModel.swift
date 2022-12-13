//
//  SearchViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import RxCocoa
import RxSwift

enum SourceScreen {
    case home
    case discover
}

extension SearchViewModel {
    struct Configs {
        static let minCharacterForSearch = 2
        static let minCharacterForTrackingFirebaseEvent = 3
        static let maximumCharacterForSavingRecentKeyword = 3
    }
}

final class SearchViewModel {
    private let disposeBag = DisposeBag()
    private let useCase: SearchUseCase
    private let provider: AttorneyAPI
    private var isFirstTime: Bool = false
    private var searchText: String?

    let textChangeEvent = BehaviorRelay<String>(value: "")
    let selectItem = PublishRelay<SearchItemType>()
    let searchAllEvent = PublishRelay<SearchAllResponse>()
    let allDataEmptyEvent = PublishRelay<Bool>()
    let editingDidEndOnExitEvent = PublishRelay<Void>()
    let goToProfileEvent = PublishSubject<String?>()
    let goToPostDetailEvent = PublishSubject<String?>()

    init(provider: AttorneyAPI, useCase: SearchUseCase, userInfo: UserInfo? = UserService.shared.userInfo) {
        self.useCase = useCase
        self.provider = provider
    }

    func viewDidLoad() {
        react()
    }

    private func react() {
        selectItem.subscribe(onNext: { [weak self] selectedItemType in
            self?.saveRecentSearchKeyword(keyword: self?.textChangeEvent.value.trim() ?? "")

            switch selectedItemType {
            case .userItem(user: let user):
                self?.goToProfileEvent.onNext(user.id)

            case .postItem(post: let post):
                self?.goToPostDetailEvent.onNext(post._id)
            }
        }).disposed(by: disposeBag)

        subscribeSearchAllEvent()
    }

    private func subscribeSearchAllEvent() {
        textChangeEvent
            .filter { $0.count >= Configs.minCharacterForSearch }
            .subscribe(onNext: { [weak self] textSearch in
                guard let strongSelf = self, !textSearch.isEmpty else { return }
                strongSelf.handleSubcribeSearch(withText: textSearch.trim())
            }).disposed(by: disposeBag)

        editingDidEndOnExitEvent
            .withLatestFrom(textChangeEvent)
            .filter { $0.count == 1 }
            .asObservable()
            .subscribe(onNext: { [weak self] textSearch in
                guard let strongSelf = self else { return }
                strongSelf.handleSubcribeSearch(withText: textSearch)
            }).disposed(by: disposeBag)

        editingDidEndOnExitEvent
            .withLatestFrom(textChangeEvent)
            .subscribe(onNext: { [weak self] searchText in
                guard let self = self else { return }
                if searchText.trim().count >= Configs.maximumCharacterForSavingRecentKeyword {
                    self.saveRecentSearchKeyword(keyword: searchText)
                }
            }).disposed(by: disposeBag)
    }

    private func callSearchAllData(withText textSearch: String) {
        self.searchAll(searchText: textSearch)
    }

    private func searchAll(searchText: String) {
        let request = SearchAllRequest(searchText: searchText)
        self.provider
            .searchAll(request: request)
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.searchAllEvent.accept(response)

                let isEmpty = (response.users ?? []).isEmpty && (response.posts ?? []).isEmpty
                strongSelf.allDataEmptyEvent.accept(isEmpty)
            }, onFailure: { [weak self] _ in
                self?.searchAllEvent.accept(SearchAllResponse())
                self?.allDataEmptyEvent.accept(true)
            }).disposed(by: disposeBag)
    }

    private func handleSubcribeSearch(withText textSearch: String) {
        self.searchText = textSearch

        self.callSearchAllData(withText: textSearch)
    }

    private func saveRecentSearchKeyword(keyword: String) {
        // Keyword count < 3 not save
        if keyword.count < Configs.maximumCharacterForSavingRecentKeyword { return }
        UserService.shared.updateRecentSearchKeywords(keyword: keyword.trim())
    }
}
