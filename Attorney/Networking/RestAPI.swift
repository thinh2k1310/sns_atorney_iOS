//
//  RestAPI.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Alamofire
import Foundation
import Moya
import RxCocoa
import RxSwift

class RestAPI: AttorneyAPI {
    let attorneyProvider: AttorneyNetworking
    
    init(attorneyProvider: AttorneyNetworking) {
        self.attorneyProvider = attorneyProvider
    }
}
