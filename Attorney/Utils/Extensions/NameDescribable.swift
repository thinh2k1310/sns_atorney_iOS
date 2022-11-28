//
//  NameDescribable.swift
//  Attorney
//
//  Created by ThinhTCQ on 11/17/22.
//

import UIKit

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}

extension UIView: NameDescribable {}
