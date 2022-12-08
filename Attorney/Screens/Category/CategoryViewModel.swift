//
//  CategoryViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import Foundation
import RxSwift

enum Category: String {
    case Administrative
    case Constitutional
    case Finance
    case Land
    case Civil
    case Labour
    case Marriage = "Marriage and Family"
    case Criminal
    case Criminal_Procedure = "Criminal Procedure"
    case Civil_Procedure = "Civil Procedure"
    case Economic = "Economic"
    case International = "International"
}

final class CategoryViewModel: ViewModel {
    
    let categories: [Category] = [.Administrative, .Civil, .Civil_Procedure, .Constitutional, .Criminal, .Civil_Procedure,
                                  .Economic, .Finance, .International, .Labour, .Land, .Marriage]
}
