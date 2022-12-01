//
//  AttorneyAPIProtocol.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Foundation
import Moya
import RxSwift

protocol AttorneyAPI {
    // MARK: - Auth
    func login(email: String, password: String) -> Single<LoginResponse>
    func register(registerRequest: RegisterRequest) -> Single<RegisterResponse>
    func validateEmail(validateEmailRequest: ValidateEmailRequest) -> Single<ValidateEmailResponse>
    func sendOTP(sendOTPRequest: SendOTPRequest) -> Single<SendOTPResponse>
    func resetPassword(resetPasswordRequest: ResetPasswordRequest) -> Single<ResetPasswordResponse>
    
    // MARK: - Post
    func fetchNewsFeed(request: PostsRequest) -> Single<PostsResponse>
    func getPostDetail(postId: String) -> Single<PostDetailResponse>
    func getPostComments(postId: String) -> Single<PostCommentsResponse>
    func likePost(likeRequest: LikeRequest) -> Single<LikeResponse>
    func commentPost(commentRequest: CommentRequest) -> Single<CommonReponse>
    func deleteComment(commentId: String) -> Single<CommonReponse>
    func sendDefenceRequest(sendDefenceRequest: DefenceRequest) -> Single<CommonReponse>
    func createPost(createPostRequest: CreatePostRequest) -> Single<CommonReponse>
}
