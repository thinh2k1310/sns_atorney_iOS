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
    
    func fetchUserPost(request: UserPostsRequest) -> Single<PostsResponse> {
        return requestObject(.fetchUserPost(request: request), type: PostsResponse.self)
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
    
    func getAllCase() -> Single<CasesResponse> {
        return requestObject(.getAllCase, type: CasesResponse.self)
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
    
    func getProfile(userId: String) -> Single<ProfileResponse> {
        return requestObject(.getProfile(userId: userId), type: ProfileResponse.self)
    }
    
    func changeAvatar(request: ChangeAvatarRequest) -> Single<ChangeImageResponse> {
        return requestObject(.changeAvatar(request: request), type: ChangeImageResponse.self)
    }
    
    func changeCover(request: ChangeCoverRequest) -> Single<ChangeImageResponse> {
        return requestObject(.changeCover(request: request), type: ChangeImageResponse.self)
    }
    
    func changePassword(request: ChangePasswordRequest) -> Single<ChangePasswordResponse> {
        return requestObject(.changePassword(request: request), type: ChangePasswordResponse.self)
    }
    
    func getAttorney(request: ListAttorneyRequest) -> Single<ListAttorneyResponse> {
        return requestObject(.getAttorney(request: request), type: ListAttorneyResponse.self)
    }
    
    func postReview(request: ReviewRequest) -> Single<CommonReponse> {
        return requestObject(.postReview(request: request), type: CommonReponse.self)
    }
    
    func getAttorneyReview(attorneyId: String) -> Single<ReviewResponse> {
        return requestObject(.getAttorneyReview(attorneyId: attorneyId), type: ReviewResponse.self)
    }
    
    func searchAll(request: SearchAllRequest) -> Single<SearchAllResponse> {
        return requestObject(.searchAll(request: request), type: SearchAllResponse.self)
    }
    
    func searchUsers(request: SearchUsersRequest) -> Single<SearchUsersResponse> {
        return requestObject(.searchUsers(request: request), type: SearchUsersResponse.self)
    }
    
    func searchPosts(request: SearchPostsRequest) -> Single<SearchPostsResponse> {
        return requestObject(.searchPosts(request: request), type: SearchPostsResponse.self)
    }
    
    func getCaseComments(caseId: String) -> Single<CaseCommentsResponse> {
        return requestObject(.getCaseComments(caseId: caseId), type: CaseCommentsResponse.self)
    }
    
    func commentCase(commentRequest: CaseCommentRequest) -> Single<CommonReponse> {
        return requestObject(.commentCase(commentRequest: commentRequest), type: CommonReponse.self)
    }
    
    func deleteCaseComment(commentId: String) -> Single<CommonReponse> {
        return requestObject(.deleteCaseComment(commentId: commentId), type: CommonReponse.self)
    }
    
    func editComment(editCmtRequest: EditCommentRequest) -> Single<CommonReponse> {
        return requestObject(.editComment(editCmtRequest: editCmtRequest), type: CommonReponse.self)
    }
    
    func editPost(editPostRequest: EditPostRequest) -> Single<CommonReponse> {
        return requestObject(.editPost(editPostRequest: editPostRequest), type: CommonReponse.self)
    }
    
    func deletePost(postId: String) -> Single<CommonReponse> {
        return requestObject(.deletePost(postId: postId), type: CommonReponse.self)
    }
    
    func report(request: ReportRequest) -> Single<CommonReponse> {
        return requestObject(.report(request: request), type: CommonReponse.self)
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
