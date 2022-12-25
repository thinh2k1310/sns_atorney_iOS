//
//  PostDetailViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/26/22.
//

import Foundation
import RxSwift

final class PostDetailViewModel: ViewModel {
    
    let postDetailEvent = PublishSubject<PostDetailResult>()
    let postCommentsEvent = PublishSubject<[Comment]>()
    let sendDefenceRequest = PublishSubject<(Bool,String)>()
    let addCommentSuccess = PublishSubject<Void>()
    let deleteCommentSuccess = PublishSubject<Void>()
    let reloadComment = PublishSubject<Void>()
    let updateLikeEvent = PublishSubject<Bool>()
    
    var post: PostDetail?
    var comments: [Comment] = []
    var postId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subcribeReloadComment()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        getPostDetail()
        getPostComments()
    }
    
    
    func getPostDetail() {
        guard let postId = postId else {
            return
        }
        
        provider
            .getPostDetail(postId: postId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    guard let post = response.data else { return }
                    self.post = post
                    self.postDetailEvent.onNext(.successAPI(post: post))
                } else {
                    self.postDetailEvent.onNext(.errorAPI(message: response.message ?? ""))
                }
            }, onFailure: { error in
                if let attorneyError = error as? AttorneyError {
                    self.postDetailEvent.onNext(.errorAPI(message: attorneyError.description))
                } else {
                    self.postDetailEvent.onNext(.errorAPI(message: error.localizedDescription))
                }
            }).disposed(by: disposeBag)
    }
    
    func getPostComments() {
        guard let postId = postId else {
            return
        }
        
        provider.getPostComments(postId: postId)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    guard let comments = response.data else { return }
                    self.comments = comments
                    self.postCommentsEvent.onNext(comments)
                } else {
                    self.postDetailEvent.onNext(.errorAPI(message: response.message ?? ""))
                }
            }, onFailure: { error in
                if let attorneyError = error as? AttorneyError {
                    self.postDetailEvent.onNext(.errorAPI(message: attorneyError.description))
                } else {
                    self.postDetailEvent.onNext(.errorAPI(message: error.localizedDescription))
                }
            }).disposed(by: disposeBag)
    }
    
    func likePost(postId: String) {
        guard let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo),
        let userId = userInfo.id else {
           return
        }
        provider
            .likePost(likeRequest: LikeRequest(userId: userId, postId: postId))
            .subscribe(onSuccess:  { [weak self] response in
                print("Liked post")
                if let isLike = response.like {
                    self?.updateLikeEvent.onNext(isLike)
                }
            }).disposed(by: disposeBag)
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
    
    func commentPost(postId: String, content: String) {
        guard let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo),
        let userId = userInfo.id else {
           return
        }
        provider
            .commentPost(commentRequest: CommentRequest(userId: userId, postId: postId, content: content))
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success {
                    if success {
                        self.addCommentSuccess.onNext(())
                    }
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
    }
    
    func deleteComment(commentId: String) {
        provider.deleteComment(commentId: commentId)
            .subscribe { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success {
                    if success {
                        self.deleteCommentSuccess.onNext(())
                    }
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
    }
    
    private func subcribeReloadComment() {
        addCommentSuccess.subscribe(onNext: { [weak self] in
            self?.getPostComments()
            self?.reloadComment.onNext(())
        }).disposed(by: disposeBag)
        
        deleteCommentSuccess.subscribe(onNext: { [weak self] in
            self?.getPostComments()
        }).disposed(by: disposeBag)
    }
    
    func sizeForHeaderView() -> CGFloat {
        guard let post = post else { return 0}
        let width = UIScreen.main.bounds.width
        var imageHeight: CGFloat = 0
        if let image = post.mediaUrl, !image.isEmpty {
            imageHeight = width * CGFloat ((post.mediaHeight ?? 1) / (post.mediaWidth ?? 1))
        }
        let textviewHeight = (post.content ?? "").heightAsLabel(withConstrainedWidth: width - 20, font: UIFont.appFont(size: 14), numberOfLines: 0)
        return (textviewHeight + imageHeight + 10 + 116)
    }
    
    func cellSizeForComment(at index: Int) -> CGFloat {
        guard !comments.isEmpty else { return 0}
        let width = UIScreen.main.bounds.width
        let comment = comments[index]
        let contentHeight = (comment.content ?? "").heightAsLabel(withConstrainedWidth: width - 96, font: UIFont.appFont(size: 14), numberOfLines: 0)
        return (contentHeight + 24 + 12 + 21 + 15)
    }
}

enum PostDetailResult {
    case successAPI(post: PostDetail)
    case errorAPI(message: String)
}
