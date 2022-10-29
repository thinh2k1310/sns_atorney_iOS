//
//  Response+Codable.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/29/22.
//

import Foundation
import Moya

public extension Response {
    // MARK:
    func mapObject<T: Codable>(_ type: T.Type, path: String? = nil) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: try getJsonData(path))
        } catch DecodingError.keyNotFound(let key, let context) {
            log.error("Failed to decode \(T.self) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
            throw MoyaError.jsonMapping(self)
        } catch DecodingError.typeMismatch(_, let context) {
            log.error("Failed to decode \(T.self) from bundle due to type mismatch – \(context.debugDescription)")
            throw MoyaError.jsonMapping(self)
        } catch DecodingError.valueNotFound(let type, let context) {
            log.error("Failed to decode \(T.self) from bundle due to missing \(type) value – \(context.debugDescription)")
            throw MoyaError.jsonMapping(self)
        } catch DecodingError.dataCorrupted(_) {
            log.error("Failed to decode \(T.self) from bundle because it appears to be invalid JSON")
            throw MoyaError.jsonMapping(self)
        } catch {
            log.error("Failed to decode \(T.self) from bundle: \(error.localizedDescription)")
            throw MoyaError.jsonMapping(self)
        }
    }

    // MARK:
    func mapArray<T: Codable>(_ type: T.Type, path: String? = nil) throws -> [T] {
        do {
            return try JSONDecoder().decode([T].self, from: try getJsonData(path))
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }

    // MARK:
    private func getJsonData(_ path: String? = nil) throws -> Data {
        do {
            var jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            if let path = path {
                guard let specificObject = jsonObject.value(forKeyPath: path) else {
                    throw MoyaError.jsonMapping(self)
                }
                jsonObject = specificObject as AnyObject
            }

            return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }
}
