//
//  UserDefaultExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/19/22.
//

import Foundation

extension UserDefaults {
    func saveObject<T: Codable>(_ object: T, forKey: String) {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: forKey)
        } catch {
            print("Error encoding: \(error)")
        }
    }

    func retrieveObject<T: Codable>(forKey: String) -> T? {
        do {
            guard let data = UserDefaults.standard.data(forKey: forKey) else {
                return nil
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error decoding: \(error)")
            return nil
        }
    }
}
