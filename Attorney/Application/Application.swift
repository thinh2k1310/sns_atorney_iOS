//
//  Application.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Alamofire
import Foundation
import Realm
import RealmSwift
import RxSwift

final class Application: NSObject {
    static let shared = Application()
    
    var provider: AttorneyAPI!
    
    override private init() {
        super.init()
    }
    
    func setProvider(provider: AttorneyAPI) {
        self.provider = provider
    }
}
