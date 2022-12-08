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
    func fetchUserPost(request: UserPostsRequest) -> Single<PostsResponse>
    func getPostDetail(postId: String) -> Single<PostDetailResponse>
    func getPostComments(postId: String) -> Single<PostCommentsResponse>
    func likePost(likeRequest: LikeRequest) -> Single<LikeResponse>
    func commentPost(commentRequest: CommentRequest) -> Single<CommonReponse>
    func deleteComment(commentId: String) -> Single<CommonReponse>
    func createPost(createPostRequest: CreatePostRequest) -> Single<CommonReponse>
    
    // MARK: - Case
    func sendDefenceRequest(sendDefenceRequest: DefenceRequest) -> Single<CommonReponse>
    func getDefenceRequest() -> Single<DefenceRequestResponse>
    func acceptDefenceRequest(requestId: String) -> Single<CommonReponse>
    func denyDefenceRequest(requestId: String) -> Single<CommonReponse>
    
    func getAllCase() -> Single<DefenceRequestResponse>
    func completeCase(caseId: String) -> Single<CommonReponse>
    func cancelCase(caseId: String) -> Single<CommonReponse>
    func getCaseDetail(caseId: String) -> Single<CaseDetailResponse>
    
    // MARK: - Profile
    func getProfile(userId: String) -> Single<ProfileResponse>
    func changeAvatar(request: ChangeAvatarRequest) -> Single<ChangeImageResponse>
    func changeCover(request: ChangeCoverRequest) -> Single<ChangeImageResponse>
    func changePassword(request: ChangePasswordRequest) -> Single<ChangePasswordResponse>
    
    // MARK: - Search
    func getAttorney(request: ListAttorneyRequest) -> Single<ListAttorneyResponse>
    
    // MARK: - Review
    func postReview(request: ReviewRequest) -> Single<CommonReponse>
    func getAttorneyReview(attorneyId: String) -> Single<ReviewResponse>
}
