//
//  AttorneyAPI.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Foundation
import Moya
import RxSwift

enum AttorneySNSAPI {
    // MARK: - Auth
    case loginOTP(loginOTPRequest: LoginRequest)
    case register(registerRequest: RegisterRequest)
    case validateEmail(validateEmailRequest: ValidateEmailRequest)
    case sendOTP(sendOTPRequest: SendOTPRequest)
    case resetPassword(resetPasswordRequest: ResetPasswordRequest)
    case fetchNewsFeed(request: PostsRequest)
    case fetchUserPost(request: UserPostsRequest)
    case getPostDetail(postId: String)
    case getPostComments(postId: String)
    case likePost(likeRequest: LikeRequest)
    case commentPost(commentRequest: CommentRequest)
    case deleteComment(commentId: String)
    case sendDefenceRequest(sendDefenceRequest: DefenceRequest)
    case createPost(createPostRequest: CreatePostRequest)
    case getDefenceRequest
    case acceptDefenceRequest(requestId: String)
    case denyDefenceRequest(requestId: String)
    case getAllCase
    case completeCase(caseId: String)
    case cancelCase(caseId: String)
    case getCaseDetail(caseId: String)
}

extension AttorneySNSAPI: TargetType {
    var baseURL: URL {
        let url = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        return URL(string: "http://localhost:3001/api")!
    }
    
    var path: String {
        switch self {
        case .loginOTP:
            return "auth/login"
        
        case .register:
            return "auth/register"
            
        case .validateEmail:
            return "auth/validate"
            
        case .sendOTP:
            return "auth/sendOTP"
            
        case .resetPassword:
            return "auth/password/reset"
            
        case .fetchNewsFeed:
            return "post/news"
            
        case .fetchUserPost:
            return "post/user"
        
        case .getPostDetail(let postId):
            return "post/\(postId)"
            
        case .getPostComments(let postId):
            return "post/\(postId)/comments"
            
        case .likePost:
            return "like"
            
        case .commentPost:
            return "comment"
        
        case .deleteComment(let commentId):
            return "comment/\(commentId)"
        
        case .sendDefenceRequest:
            return  "case/request"
            
        case .createPost:
            return "post/create"
            
        case .getDefenceRequest:
            return "case/request"
        
        case .acceptDefenceRequest(let requestId):
            return "case/request/\(requestId)/accept"
            
        case .denyDefenceRequest(let requestId):
            return "case/request/\(requestId)/cancel"
            
        case .getAllCase:
            return "case/list"
            
        case .completeCase(let caseId):
            return "case/\(caseId)/complete"
        
        case .cancelCase(let caseId):
            return "case/\(caseId)/cancel"
            
        case .getCaseDetail(let caseId):
            return "case/\(caseId)"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .loginOTP, .register, .fetchNewsFeed, .likePost, .commentPost, .sendDefenceRequest, .createPost, .fetchUserPost:
            return .post
        
        case .validateEmail, .sendOTP, .resetPassword, .acceptDefenceRequest, .completeCase, .cancelCase:
            return .put
            
        case .deleteComment, .denyDefenceRequest:
            return .delete
    
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }

    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .loginOTP(let loginOTPRequest):
            return .requestJSONEncodable(loginOTPRequest)
        case .register(let registerRequest):
            return .requestJSONEncodable(registerRequest)
        case .validateEmail(let validateEmailRequest):
            return .requestJSONEncodable(validateEmailRequest)
        case .sendOTP(let sendOTPRequest):
            return .requestJSONEncodable(sendOTPRequest)
        case .resetPassword(let resetPasswordRequest):
            return .requestJSONEncodable(resetPasswordRequest)
        case .fetchNewsFeed(let request):
            return .requestJSONEncodable(request)
        case .commentPost(let commentRequest):
            return .requestJSONEncodable(commentRequest)
        case .likePost(let likeRequest):
            return .requestJSONEncodable(likeRequest)
        case .sendDefenceRequest(let sendDefenceRequest):
            return .requestJSONEncodable(sendDefenceRequest)
        case .fetchUserPost(let request):
            return .requestJSONEncodable(request)
        
        case .createPost(let request):
            var multidata = [
                MultipartFormData(provider: .data(request.content.data(using: String.Encoding.utf8, allowLossyConversion: false)!) , name :"content"),
                MultipartFormData(provider: .data(request.type.data(using: String.Encoding.utf8, allowLossyConversion: false)!), name :"type")
            ]
            if let media = request.media {
                guard let data = media.jpegData(compressionQuality: 1.0) else { return .requestPlain }
                multidata.append(MultipartFormData(provider: .data(data), name: "media", fileName: "photo.jpg", mimeType:"image/jpeg"))
            }
            return .uploadMultipart(multidata)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headersValue: [String: String] = [:]
        guard let token = UserService.shared.accessToken else { return headersValue }
        headersValue = ["Authorization" : "Bearer \(token)"]
        return headersValue
    }
    
    
}
