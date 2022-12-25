//
//  ProfileViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 04/12/2022.
//

import Foundation

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

final class ProfileViewModel: ViewModel {
    let dataSources = BehaviorSubject<[SectionModel<String, Post>]>(value: createLoadingModelDataSources())
    let loadMoreEvent = PublishSubject<Void>()
    let resetPageEvent = PublishSubject<Void>()
    let sendDefenceRequest = PublishSubject<(Bool,String)>()
    let isLoading = BehaviorRelay<Bool>(value: true)
    let getProfileSuccess = PublishSubject<User>()
    
    var canLoadMore = true
    var isFirstLoad = true
    var title = ""
    
    private var posts: [Post] = []
    
    var profileId : String?
    
    var profile: User?

    private let numberPerPage = 15
    private var currentPage = 1
    private var countPage = 1
    var lastIndexItemOfPage: Int {
       numberPerPage * countPage - 1
    }
    var isLoadingNewPage: Bool {
        currentPage < maxPage && (countPage + 1) * numberPerPage >= posts.count
    }
    private var maxPage = 1 // by default maxPage = 1
    
    override func setupData() {
        getProfile() 
        binding()
    }
    
    private func binding() {
        self.bodyLoading.asObservable().bind(to: isLoading).disposed(by: disposeBag)

        loadMoreEvent.subscribe { [weak self] _ in
            guard let self = self else {return}
            if self.canLoadMore {
                self.countPage += 1
                self.loadPostData(pageIndex: self.countPage)
            }
        }.disposed(by: disposeBag)
        
    }
    
    func resetPage() {
        currentPage = 1
        countPage = 1
        maxPage = 1
        canLoadMore = true
        isFirstLoad = true
        resetPageEvent.onNext(())
        dataSources.onNext(ProfileViewModel.createLoadingModelDataSources())
        posts.removeAll()
    }

    private func loadPostData(pageIndex: Int) {
        let currentRecordsCount = countPage * numberPerPage
        // Max record of page
        if currentPage >= maxPage && currentRecordsCount >= posts.count {
            self.canLoadMore = false
            self.dataSources.onNext(self.makeSources(posts: posts))
            return
        }

        if currentPage < maxPage && currentRecordsCount >= posts.count {
            // fetch API get next page (100 records)
            currentPage += 1
            getPosts()
            return
        }

        var currentPosts = [Post]()
        if currentRecordsCount <= posts.count {
            currentPosts = Array(posts[0..<currentRecordsCount])
        }

        // Set delay time for render footer loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.dataSources.onNext(self.makeSources(posts: currentPosts))
        })
    }

    private func makeSources(posts: [Post]) -> [SectionModel<String, Post>] {
        return [SectionModel(model: "", items: posts)]
    }
    
    static func createLoadingModelDataSources() -> [SectionModel<String, Post>] {
        var items = [Post]()
        for _ in 0..<5 {
            items.append(Post(byDefaultValue: true))
        }
        return [SectionModel<String, Post>(model: "", items: items)]
    }
    
    func getProfile() {
        guard let profileId = profileId else {
            return
        }
        provider
            .getProfile(userId: profileId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe { [weak self] (userResponse) in
                guard let self = self else { return }
                if let success = userResponse.success, success {
                    if let user = userResponse.data {
                        self.profile = userResponse.data
                        self.getProfileSuccess.onNext(user)
                    }
                }
            } onFailure: { (_) in
                print("fetch profile failed")
            }.disposed(by: disposeBag)
    }
    
    func getPosts() {
        guard let profileId = profileId else {
            return
        }

        let request = UserPostsRequest(profileId: profileId, pageNumber: currentPage)
        provider
            .fetchUserPost(request: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe { [weak self] (postsResponse) in
                guard let self = self else { return }
                if let pageConfig = postsResponse.metadata, let postsList = postsResponse.data {
                    self.isFirstLoad = false
                    self.maxPage = pageConfig.pages ?? 1
                    self.currentPage = pageConfig.page ?? 1
                    self.posts += postsList
                    self.loadPostData(pageIndex: self.countPage)
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
    }
    
    func likePost(postId: String) {
        guard let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo),
        let userId = userInfo.id else {
           return
        }
        provider
            .likePost(likeRequest: LikeRequest(userId: userId, postId: postId))
    }
    
    func sendDefenceRequest(postId: String, customerId: String) {
        guard let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo),
        let userId = userInfo.id else {
           return
        }
        provider
            .sendDefenceRequest(sendDefenceRequest: DefenceRequest(attorneyId: userId, postId: postId, customerId: customerId))
            .subscribe { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success, let message = response.message {
                    self.sendDefenceRequest.onNext((success, message))
                    log.debug("Thinh test \(message)")
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
        
    }
}

// MARK: - Cell Size calculation
extension ProfileViewModel {
    func cellSizeForPost(at index: Int, withConstrainedCellWidth cellWidth: CGFloat) -> CGSize {
        guard !posts.isEmpty else { return .zero }
        let post = posts[index]
        // Image view height
        var imageHeight: CGFloat = 0
        if let image = post.mediaUrl, !image.isEmpty {
            imageHeight = cellWidth * CGFloat ((post.mediaHeight ?? 1) / (post.mediaWidth ?? 1))
        }
        let contentHeight = (post.content ?? "").heightAsTextView(withConstrainedWidth: cellWidth - 20, font: UIFont.appFont(size: 14), numberOfLines: 5)
        let showMoreButtonHeight : CGFloat = contentHeight > 90 ? 30 : 0
        //70+116+30+10
        let cellHeight = imageHeight + contentHeight + showMoreButtonHeight + 196
        let correctSize: CGSize = CGSize(width: cellWidth, height: cellHeight)
        return correctSize
    }
}
