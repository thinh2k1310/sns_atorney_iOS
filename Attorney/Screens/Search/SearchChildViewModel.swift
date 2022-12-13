//
//  SearchChildViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

import Differentiator
import RxCocoa
import RxSwift

enum SearchScreenType: Int, CaseIterable {
    case searchAll
    case searchPosts
    case searchUsers
    
    var title: String {
        switch self {
        case .searchAll:
            return "All"
        case .searchPosts:
            return "Posts"
        case .searchUsers:
            return "Users"
        }
    }
}

extension SearchChildViewModel {
    struct Configs {
        static let postsHeaderTitle = "Posts"
        static let usersHeaderTitle = "Users"
        static let maximumDisplayCount = 3
        static let maximumCharacterForSavingRecentKeyword = 3
        static let minimumHeight: CGFloat = 0.00001
        static let searchKrisShopHeight: CGFloat = 82
    }
}

final class SearchChildViewModel {
    let provider: AttorneyAPI
    let disposeBag = DisposeBag()

    let dataSource = BehaviorSubject<[SectionModel<String, SearchItemType>]>.init(value: [SectionModel<String, SearchItemType>]())
    let textChangeEvent = BehaviorRelay<String>(value: "")
    let selectItem = PublishRelay<SearchItemType>.init()
    let tabSelectedEvent = PublishRelay<SearchScreenType>()
    let clearSearchButtonEvent = PublishRelay<Void>()
    let emptyDataEvent = PublishRelay<Bool>()
    let searchWithKeywordsViewModel = SearchDiscoverKeywordsViewModel()
    let didSelectKeywordsEvent = PublishRelay<String>()
    let displaySearchKeywordEvent = PublishRelay<Bool>()
    let didTapKrisShopEvent = PublishRelay<Void>()
    let searchAllEvent = BehaviorRelay<SearchAllResponse>.init(value: SearchAllResponse())
    let clickShowAllEvent = PublishRelay<SearchScreenType>()
    let loadMoreEvent = PublishRelay<Void>()
    let recentKeywords = BehaviorRelay<[String]>(value: UserService.shared.getRecentSearchKeywords())
    let popularKeywords = BehaviorRelay<[String]>(value: [])

    var searchType: SearchScreenType = .searchAll
    private var users = [User]()
    private var posts = [Post]()
    private var metaData: SearchMetaData?
    private var currentPage = 1
    private var isLoadingMore = false

    private var isEmptyData: Bool {
        (users.isEmpty && posts.isEmpty ) ||
        (searchType == .searchUsers && users.isEmpty) ||
        (searchType == .searchPosts && posts.isEmpty)
    }

    var isEmptyKeyword: Bool {
        recentKeywords.value.isEmpty && popularKeywords.value.isEmpty
    }

    init(provider: AttorneyAPI) {
        self.provider = provider
    }

    func viewDidLoad() {
        react()
        bindingParentPageView()
        bindingSearchKeyword()
    }

    private func react() {
        switch searchType {
        case .searchAll:
            subscribeSearchAllForAllTab()

        case .searchUsers:
            subscribeSearchAllForUsersTab()
            subscribeSearchUsers()

        case .searchPosts:
            subscribeSearchAllForPostsTab()
            subscribeSearchPosts()
        }
    }

    private func subscribeSearchUsers() {
        loadMoreEvent.withLatestFrom(textChangeEvent)
            .subscribe(onNext: { [weak self] textSearch in
                guard let strongSelf = self, !textSearch.isEmpty else { return }
                strongSelf.searchUsers(searchText: textSearch.trim())
            }).disposed(by: disposeBag)
    }
    
    private func subscribeSearchAllForUsersTab() {
        searchAllEvent.subscribe(onNext: { [weak self] searchAllResponse in
            guard let strongSelf = self else { return }
            strongSelf.users = searchAllResponse.users ?? []
            strongSelf.currentPage = 1
            strongSelf.makeSources()
        }).disposed(by: disposeBag)
    }
    
    private func subscribeSearchAllForPostsTab() {
        searchAllEvent.subscribe(onNext: { [weak self] searchAllResponse in
            guard let strongSelf = self else { return }
            strongSelf.posts = searchAllResponse.posts ?? []
            strongSelf.currentPage = 1
            strongSelf.makeSources()
        }).disposed(by: disposeBag)
    }

    private func subscribeSearchPosts() {
        loadMoreEvent.withLatestFrom(textChangeEvent)
            .subscribe(onNext: { [weak self] textSearch in
                guard let strongSelf = self, !textSearch.isEmpty else { return }
                strongSelf.searchPosts(searchText: textSearch.trim())
            }).disposed(by: disposeBag)
    }

    private func subscribeSearchAllForAllTab() {
        searchAllEvent.skip(1)
            .subscribe(onNext: { [weak self] searchAllResponse in
                guard let strongSelf = self else { return }
                strongSelf.users = searchAllResponse.users ?? []
                strongSelf.posts = searchAllResponse.posts ?? []
                strongSelf.makeSources()
            }).disposed(by: disposeBag)
    }


    private func makeSources() {
        self.isLoadingMore = false
        if isEmptyData {
            emptyDataEvent.accept(true)
            searchWithKeywordsViewModel.noSearchResultSubject.onNext(true)
//            handleSearchKeywordsData()
            return
        }

        emptyDataEvent.accept(false)
        switch searchType {
        case .searchAll:
            var dataSourceModels = [SectionModel<String, SearchItemType>]()

            if !users.isEmpty {
                let usersItem = users.prefix(Configs.maximumDisplayCount).map { SearchItemType.userItem(user: $0) }
                dataSourceModels.append(SectionModel(model: Configs.usersHeaderTitle.uppercased(), items: usersItem))
            }

            if !posts.isEmpty {
                let postModels = posts.prefix(Configs.maximumDisplayCount).map { SearchItemType.postItem(post: $0) }
                dataSourceModels.append(SectionModel(model: Configs.postsHeaderTitle.uppercased(), items: postModels))
            }

            dataSource.onNext(dataSourceModels)

        case .searchUsers:
            let userModels = [SectionModel(model: "", items: users.map { SearchItemType.userItem(user: $0) })]
            dataSource.onNext(userModels)

        case .searchPosts:
            let postItems = posts.map { SearchItemType.postItem(post: $0) }
            let postModels = [SectionModel(model: "", items: postItems)]
            dataSource.onNext(postModels)
        }
    }

    private func bindingSearchKeyword() {
        UserService.shared.recentKeywordsChangedEvent
            .bind(to: self.recentKeywords)
            .disposed(by: disposeBag)
        subcribeRecentlySearchKeyword()
    }

    private func bindingParentPageView() {
        textChangeEvent
            .filter { _ in self.searchType == .searchAll }
            .skip(while: { $0.isEmpty })
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.searchWithKeywordsViewModel.noSearchResultSubject.onNext(false)
                self?.clearSearchButtonEvent.accept(())
            }).disposed(by: disposeBag)

        clearSearchButtonEvent.subscribe(onNext: { [weak self] in
            self?.searchWithKeywordsViewModel.noSearchResultSubject.onNext(false)
        }).disposed(by: disposeBag)
    }

    private func subcribeRecentlySearchKeyword() {
        recentKeywords
            .filter { _ in self.searchType == .searchAll }
            .skip(while: { $0.isEmpty })
            .subscribe(onNext: { [weak self] listRecentKeywords in
                guard let self = self else { return }
                self.setupDataRecentKeywords(withKeywords: listRecentKeywords)
            }).disposed(by: disposeBag)
    }
}

// MARK: - APIs call
extension SearchChildViewModel {
    private func searchUsers(searchText: String) {
        let searchRequest = SearchUsersRequest(searchText: searchText, pageNumber: self.currentPage + 1)
        self.provider
            .searchUsers(request: searchRequest)
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.currentPage += 1
                if let users = response.data {
                    strongSelf.users += users
                }
                strongSelf.makeSources()
            }, onFailure: { [weak self] _ in
                self?.isLoadingMore = false
            }).disposed(by: disposeBag)
    }

    private func searchPosts(searchText: String) {
        let searchRequest = SearchPostsRequest(searchText: searchText, pageNumber: self.currentPage + 1)
        self.provider
            .searchPosts(request: searchRequest)
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                strongSelf.currentPage += 1
                if let posts = response.data {
                    strongSelf.posts += posts
                }
                strongSelf.makeSources()
            }, onFailure: { [weak self] _ in
                self?.isLoadingMore = false
            }).disposed(by: disposeBag)
    }
}

// MARK: Custom View
extension SearchChildViewModel {
    private func setupDataRecentKeywords(withKeywords keywords: [String]) {
        self.searchWithKeywordsViewModel.recentSearchsSubject.onNext(keywords)
        displaySearchKeywordEvent.accept(isEmptyData)
    }
}

// MARK: Public function

extension SearchChildViewModel {
    func getSearchType() -> SearchScreenType {
        return self.searchType
    }

    func setSearchScreenType(type: SearchScreenType) {
        self.searchType = type
    }

    func getUsers(at index: Int) -> User? {
        return self.users[index]
    }

    func getPosts(at index: Int) -> Post? {
        return self.posts[index]
    }

    func canLoadMore(atSection section: Int) -> Bool {
            let maximumPages = (metaData?.pages ?? 0)
            return currentPage < maximumPages
    }

    func shouldShowFooterView(atSection section: Int) -> Bool {
            return true
    }

    func showAllResults(at section: Int) {
        if let sectionModel = try? dataSource.value()[section] {
            switch sectionModel.items.first {
            case .userItem:
                self.clickShowAllEvent.accept(.searchUsers)

            case .postItem:
                self.clickShowAllEvent.accept(.searchPosts)

            default:
                break
            }
        }
    }

    func handleLoadmore(cellIndex: Int) {
        if !canLoadMore(atSection: 0) || isLoadingMore { return }
        if (searchType == .searchUsers && cellIndex == users.count - 1) ||
            (searchType == .searchPosts && cellIndex == posts.count - 1) {
            self.isLoadingMore = true
            self.loadMoreEvent.accept(())
        }
    }
}

// MARK: - Header & Footer height
extension SearchChildViewModel {
    func getHeaderSizeForSection(at section: Int, withConstrainedCellWidth cellWidth: CGFloat) -> CGSize {
        switch getSearchType() {
        case .searchAll:
            let headerHeight = CGFloat(30)
            return CGSize(width: cellWidth, height: headerHeight)

        case .searchUsers, .searchPosts:
            break
        }
        return CGSize(width: .zero, height: Configs.minimumHeight)
    }

    func getFooterSizeForSection(at section: Int, withConstrainedCellWidth cellWidth: CGFloat) -> CGSize {
        // Header height = zero for section search on krisshop
        let footerHeight = CGFloat(70)
        switch getSearchType() {
        case .searchAll:
            return CGSize(width: cellWidth, height: footerHeight)

        case .searchUsers, .searchPosts:
            if canLoadMore(atSection: section) {
                return CGSize(width: cellWidth, height: footerHeight)
            } else {
                return CGSize(width: .zero, height: Configs.minimumHeight)
            }
        }
    }
}

extension SearchChildViewModel {
    func getHeaderTitle(forSection section: Int) -> String? {
        if let sectionModel = try? dataSource.value()[section] {
            return sectionModel.model
        }
        return nil
    }

    func getFooterTitle(forSection section: Int) -> String? {
        switch self.getSearchType() {
        case .searchAll:
            return footerTitleForSearchAll(at: section)

        case .searchUsers, .searchPosts:
            return "Load more"
        }
    }

    private func footerTitleForSearchAll(at section: Int) -> String? {
        if let sectionModel = try? dataSource.value()[section] {
            switch sectionModel.items.first {
            case .userItem:
                return "Show all users"

            case .postItem:
                return "Show all posts"

            default:
                break
            }
        }
        return nil
    }
}

extension SearchChildViewModel {
    func cellHeightForItem(at indexPath: IndexPath, withConstrainedCellWidth cellWidth: CGFloat) -> CGFloat {
        switch self.getSearchType() {
        case .searchAll:
            // height for header search type
            return self.cellSizeForSearchAll(at: indexPath, withConstrainedCellWidth: cellWidth).height

        case .searchUsers:
            return 120

        case .searchPosts:
            return self.cellSizeForPost(at: indexPath.row, withConstrainedCellWidth: cellWidth).height
        }
    }

    // MARK: - Calculate cell size for search all case
    func cellSizeForSearchAll(at indexPath: IndexPath, withConstrainedCellWidth cellWidth: CGFloat) -> CGSize {
        let section = indexPath.section
        let index = indexPath.row
        if let sectionModel = try? dataSource.value()[section] {
            let item = sectionModel.items[index]
                switch item {
                case .userItem(_):
                    return CGSize(width: cellWidth, height: 120)

                case .postItem(_):
                    return cellSizeForPost(at: index, withConstrainedCellWidth: cellWidth)
                }
        }
        return .zero
    }
    
    func cellSizeForPost(at index: Int, withConstrainedCellWidth cellWidth: CGFloat) -> CGSize {
        guard !posts.isEmpty else { return .zero }
        let post = posts[index]
        // Image view height
        let contentHeight = (post.content ?? "").heightAsLabel(withConstrainedWidth: cellWidth - 20, font: UIFont.appFont(size: 14), numberOfLines: 3)
        //70+116+30+10
        let cellHeight = contentHeight + 90
        let correctSize: CGSize = CGSize(width: cellWidth, height: cellHeight)
        return correctSize
    }
}

