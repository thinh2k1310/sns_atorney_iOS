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
    
    let userInforChangeEvent = PublishSubject<UserInfo>()
    let recentKeywordsChangedEvent = PublishSubject<[String]>()

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
    
    func saveUserInfor(user: User) {
        let userInfor = UserInfo(user: user)
        UserDefaults.standard.saveObject(userInfor, forKey: UserKey.kUserInfo)
        userInforChangeEvent.onNext(userInfor)
    }
    
    func getRecentSearchKeywords() -> [String] {
        // Call reversed() to make keywords newest on top
        return (UserDefaults.standard.stringArray(forKey: UserKey.kRecentSearchKeywords) ?? [String]()).reversed()
    }

    func updateRecentSearchKeywords(keyword: String) {
        var recentKeywords = UserDefaults.standard.stringArray(forKey: UserKey.kRecentSearchKeywords) ?? [String]()

        // Not append duplicate keyword
        if recentKeywords.contains(where: {$0.lowercased().elementsEqual(keyword.lowercased())}) {
            recentKeywords.removeAll(where: {$0.lowercased().elementsEqual(keyword.lowercased())})
        }
        // Store keyword
        recentKeywords.append(keyword)
        UserDefaults.standard.set(recentKeywords, forKey: UserKey.kRecentSearchKeywords)
        UserDefaults.standard.synchronize()
        recentKeywordsChangedEvent.onNext(getRecentSearchKeywords())
    }

    func removeRecentSearchKeyword(keyword: String) {
        if var recentKeywords = UserDefaults.standard.stringArray(forKey: UserKey.kRecentSearchKeywords) {
            recentKeywords.removeAll(where: {$0.elementsEqual(keyword)})
            UserDefaults.standard.set(recentKeywords, forKey: UserKey.kRecentSearchKeywords)
            UserDefaults.standard.synchronize()
            recentKeywordsChangedEvent.onNext(getRecentSearchKeywords())
        }
    }

    func removeAllRecentSearch() {
        UserDefaults.standard.set(nil, forKey: UserKey.kRecentSearchKeywords)
        UserDefaults.standard.synchronize()
        recentKeywordsChangedEvent.onNext(getRecentSearchKeywords())
    }
}
