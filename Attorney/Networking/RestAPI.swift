//
//  RestAPI.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Alamofire
import Foundation
import Moya
import RxCocoa
import RxSwift

class RestAPI: AttorneyAPI {
    let attorneyProvider: AttorneyNetworking
    
    init(attorneyProvider: AttorneyNetworking) {
        self.attorneyProvider = attorneyProvider
    }
}

extension RestAPI {
    func login(email: String, password: String) -> Single<LoginResponse> {
        let loginRequest = LoginRequest(email: email, password: password)
        return requestObject(.loginOTP(loginOTPRequest: loginRequest), type: LoginResponse.self)
    }
    
    func register(registerRequest: RegisterRequest) -> Single<RegisterResponse> {
        return requestObject(.register(registerRequest: registerRequest), type: RegisterResponse.self)
    }
    
    func validateEmail(validateEmailRequest: ValidateEmailRequest) -> Single<ValidateEmailResponse> {
        return requestObject(.validateEmail(validateEmailRequest: validateEmailRequest), type: ValidateEmailResponse.self)
    }
    
    func sendOTP(sendOTPRequest: SendOTPRequest) -> Single<SendOTPResponse> {
        return requestObject(.sendOTP(sendOTPRequest: sendOTPRequest), type: SendOTPResponse.self)
    }
    
    func resetPassword(resetPasswordRequest: ResetPasswordRequest) -> Single<ResetPasswordResponse> {
        return requestObject(.resetPassword(resetPasswordRequest: resetPasswordRequest), type: ResetPasswordResponse.self)
    }
    
    func fetchNewsFeed(request: PostsRequest) -> Single<PostsResponse> {
        return requestObject(.fetchNewsFeed(request: request), type: PostsResponse.self)
    }
    
    func getPostDetail(postId: String) -> Single<PostDetailResponse> {
        return requestObject(.getPostDetail(postId: postId), type: PostDetailResponse.self)
    }
    
    func getPostComments(postId: String) -> Single<PostCommentsResponse> {
        return requestObject(.getPostComments(postId: postId), type: PostCommentsResponse.self)
    }
    
    func commentPost(commentRequest: CommentRequest) -> Single<CommonReponse> {
        return requestObject(.commentPost(commentRequest: commentRequest), type: CommonReponse.self)
    }
    
    func likePost(likeRequest: LikeRequest) -> Single<LikeResponse> {
        return requestObject(.likePost(likeRequest: likeRequest), type: LikeResponse.self)
    }
    
    func deleteComment(commentId: String) -> Single<CommonReponse> {
        return requestObject(.deleteComment(commentId: commentId), type: CommonReponse.self)
    }
    
    func sendDefenceRequest(sendDefenceRequest: DefenceRequest) -> Single<CommonReponse> {
        return requestObject(.sendDefenceRequest(sendDefenceRequest: sendDefenceRequest), type: CommonReponse.self)
    }
    
    func createPost(createPostRequest: CreatePostRequest) -> Single<CommonReponse> {
        return requestObject(.createPost(createPostRequest: createPostRequest), type: CommonReponse.self)
    }
    
    func getDefenceRequest() -> Single<DefenceRequestResponse> {
        return requestObject(.getDefenceRequest, type: DefenceRequestResponse.self)
    }
    
    func acceptDefenceRequest(requestId: String) -> Single<CommonReponse> {
        return requestObject(.acceptDefenceRequest(requestId: requestId), type: CommonReponse.self)
    }

    func denyDefenceRequest(requestId: String) -> Single<CommonReponse> {
        return requestObject(.denyDefenceRequest(requestId: requestId), type: CommonReponse.self)
    }
    
    func getAllCase() -> Single<DefenceRequestResponse> {
        return requestObject(.getAllCase, type: DefenceRequestResponse.self)
    }
    func completeCase(caseId: String) -> Single<CommonReponse> {
        return requestObject(.completeCase(caseId: caseId), type: CommonReponse.self)
    }

    func cancelCase(caseId: String) -> Single<CommonReponse> {
        return requestObject(.cancelCase(caseId: caseId), type: CommonReponse.self)
    }
    
    func getCaseDetail(caseId: String) -> Single<CaseDetailResponse> {
        return requestObject(.getCaseDetail(caseId: caseId), type: CaseDetailResponse.self)
    }
}

extension RestAPI {
    private func requestObject<T: Codable>(_ target: AttorneySNSAPI, type: T.Type) -> Single<T> {
        return attorneyProvider.request(target)
            .mapObject(type)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}
