//
//  SearchItemType.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/9/22.
//

enum SearchItemType {
    case postItem(post: Post)
    case userItem(user: User)
}

extension SearchItemType: Equatable {
    static func == (lhs: SearchItemType, rhs: SearchItemType) -> Bool {
        switch (lhs, rhs) {
        case (.postItem, .postItem),
            (.userItem, .userItem):
            return true

        default:
            return false
        }
    }
}
