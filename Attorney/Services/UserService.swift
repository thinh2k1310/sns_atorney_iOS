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
    fileprivate let keychain = Keychain(service: Configurations.App.bundleIdentifier ?? "thinh.com")

    public private (set) var userInfo: UserInfo?
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: token)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
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
    
    func saveInfoNameKey(nameKey: String) {
        keychain[nameKey] = nameKey
    }
    
    func getInfoNameKey(nameKey: String) -> String? {
        return keychain[nameKey]
    }

    func removeKeyFromKeychain(nameKey: String) {
        keychain[nameKey] = nil
    }
}
