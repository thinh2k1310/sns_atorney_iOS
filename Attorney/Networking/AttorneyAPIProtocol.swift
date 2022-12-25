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
    func editComment(editCmtRequest: EditCommentRequest) -> Single<CommonReponse>
    func commentPost(commentRequest: CommentRequest) -> Single<CommonReponse>
    func deleteComment(commentId: String) -> Single<CommonReponse>
    func createPost(createPostRequest: CreatePostRequest) -> Single<CommonReponse>
    func editPost(editPostRequest: EditPostRequest) -> Single<CommonReponse>
    func deletePost(postId: String) -> Single<CommonReponse>
    
    // MARK: - Case
    func sendDefenceRequest(sendDefenceRequest: DefenceRequest) -> Single<CommonReponse>
    func getDefenceRequest() -> Single<DefenceRequestResponse>
    func acceptDefenceRequest(requestId: String) -> Single<CommonReponse>
    func denyDefenceRequest(requestId: String) -> Single<CommonReponse>
    
    func getAllCase() -> Single<CasesResponse>
    func completeCase(caseId: String) -> Single<CommonReponse>
    func cancelCase(caseId: String) -> Single<CommonReponse>
    func getCaseDetail(caseId: String) -> Single<CaseDetailResponse>
    
    func getCaseComments(caseId: String) -> Single<CaseCommentsResponse>
    func commentCase(commentRequest: CaseCommentRequest) -> Single<CommonReponse>
    func deleteCaseComment(commentId: String) -> Single<CommonReponse>
   
    
    // MARK: - Profile
    func getProfile(userId: String) -> Single<ProfileResponse>
    func changeAvatar(request: ChangeAvatarRequest) -> Single<ChangeImageResponse>
    func changeCover(request: ChangeCoverRequest) -> Single<ChangeImageResponse>
    func changePassword(request: ChangePasswordRequest) -> Single<ChangePasswordResponse>
    
    // MARK: - Search
    func getAttorney(request: ListAttorneyRequest) -> Single<ListAttorneyResponse>
    func searchAll(request: SearchAllRequest) -> Single<SearchAllResponse>
    func searchUsers(request: SearchUsersRequest) -> Single<SearchUsersResponse>
    func searchPosts(request: SearchPostsRequest) -> Single<SearchPostsResponse>
    
    // MARK: - Review
    func postReview(request: ReviewRequest) -> Single<CommonReponse>
    func getAttorneyReview(attorneyId: String) -> Single<ReviewResponse>
    
    // MARK: - Report
    func report(request: ReportRequest) -> Single<CommonReponse>
}
