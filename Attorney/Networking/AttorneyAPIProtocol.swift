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
}
