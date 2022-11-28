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
    
    private var post: PostDetail?
    var postId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            })
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
            })
    }
}

enum PostDetailResult {
    case successAPI(post: PostDetail)
    case errorAPI(message: String)
}
