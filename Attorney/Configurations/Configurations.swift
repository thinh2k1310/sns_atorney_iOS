//
//  Configurations.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import Foundation
import Rswift
import RxSwift

typealias AppConfigs = Configurations.App
typealias CompletionClosure = ((_ success: Bool) -> Void)
typealias StringConstants = R.string.localizable
typealias ObservableResult<Value> = Observable<Swift.Result<Value, Error>>
let preferredLanguages = AppConfigs.preferredLanguages

struct Configurations {
    struct App {
        static var baseUrl: String? {
            return Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        }
        static var bundleIdentifier: String? {
            return Bundle.main.bundleIdentifier
        }
        static var preferredLanguages: [String]? {
            return ["en"]
        }
    }
    struct Format {
        static let dateFromServer = "yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'"
        static let dateOfBirth = "dd/MM/yyyy"
        static let dateFormatYear = "yyyy"
    }

    struct Network {
        #if DEBUG || UAT
        static let loggingEnabled = true
        #else
        static let loggingEnabled = false
        #endif
    }

    struct Title {
        
    }

    struct TabbarIndex {
        static let home = 0
        static let discorver = 1
        static let pay = 2
        static let wallet = 3
        static let account = 4
    }
}
