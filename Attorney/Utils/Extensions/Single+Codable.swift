//
//  Single+Codable.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import Moya
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func mapObject<T: Codable>(_ type: T.Type, path: String? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            Single.just(try response.mapObject(type, path: path))
        }
    }

    func mapArray<T: Codable>(_ type: T.Type, path: String? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            Single.just(try response.mapArray(type, path: path))
        }
    }
}
