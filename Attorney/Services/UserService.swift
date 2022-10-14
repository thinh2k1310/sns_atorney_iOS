//
//  UserService.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import JWTDecode
import KeychainAccess
import RxCocoa
import RxSwift

class UserService {
    static let shared = UserService()
    
    fileprivate let usernameKey = "UsernameKey"
    fileprivate let pwAccessKey = "PasswordKey"
    fileprivate let lastEmailKey = "LastEmailKey"
    fileprivate let lastPwEncryptKey = "LastPasswordKey"
    fileprivate let token = "accessToken"

    public private (set) var userInfo: UserInfo?
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: token)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
}
