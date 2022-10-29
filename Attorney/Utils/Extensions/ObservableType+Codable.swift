//
//  ObservableType+Codable.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import Moya
import RxSwift

public extension ObservableType where Element == Response {
    func mapObject<T: Codable>(_ type: T.Type, _ path: String? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            Observable.just(try response.mapObject(type, path: path))
        }
    }

    func mapArray<T: Codable>(_ type: T.Type, _ path: String? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            Observable.just(try response.mapArray(type, path: path))
        }
    }
}
