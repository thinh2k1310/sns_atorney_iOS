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
    fileprivate let userInfoKey = "UserInfoKey"
    fileprivate let pwAccessKey = "PasswordKey"
    fileprivate let lastIdKey = "LastIdKey"
    fileprivate let lastEmailKey = "LastEmailKey"
    fileprivate let token = "accessToken"
    fileprivate let keychain = Keychain(service: Configurations.App.bundleIdentifier ?? "thinh.com")

    public private (set) var userInfo: UserInfo?
    
    let disposeBag = DisposeBag()
    
    var accessToken: String? {
        return UserDefaults.standard.string(forKey: token)
    }
    
    public private (set) var loginResponse: LoginResponse?
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    var lastId: String? {
        get {
            guard let lastId = keychain[lastIdKey] else { return nil }
            return lastId
        }
        set {
            if let lastId = newValue {
                keychain[lastIdKey] = lastId
            } else {
                keychain[lastIdKey] = nil
            }
        }
    }
    
    var lastEmail: String? {
        get {
            guard let lastEmail = keychain[lastEmailKey] else { return nil }
            return lastEmail
        }
        set {
            if let lastEmail = newValue {
                keychain[lastEmailKey] = lastEmail
            } else {
                keychain[lastEmailKey] = nil
            }
        }
    }
        
    public func setLoginResponse(_ res: LoginResponse?) {
        self.loginResponse = res
    }
    
    public func setUserInfo(info: UserInfo?) {
        self.userInfo = info
    }
    
    func saveInfoNameKey(nameKey: String) {
        keychain[nameKey] = nameKey
    }
    
    func getInfoNameKey(nameKey: String) -> String? {
        return keychain[nameKey]
    }

    func removeKeyFromKeychain(nameKey: String) {
        keychain[nameKey] = nil
    }
    
    func saveAccessToken(token: String) {
        UserDefaults.standard.setValue(token, forKey: self.token)
    }
    
    func removeAccessToken() {
        UserDefaults.standard.setValue(nil, forKey: self.token)
    }
    
    class func saveLastId(id: String) {
        UserService.shared.lastId = id
    }

    class func saveLastEmail(email: String) {
        UserService.shared.lastEmail = email
    }
}
