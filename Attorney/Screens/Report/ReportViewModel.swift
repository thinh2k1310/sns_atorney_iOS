//
//  ReportViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/26/22.
//

import Foundation
import RxSwift

enum ReportCategory: String {
    case Nudity
    case Violence
    case Spam
    case Harrassment
    case Information = "False information"
    case Other = "Something else"
}

enum ReportType: String {
    case Post
    case Comment
}

final class ReportViewModel: ViewModel {
    let reportSuccess =  PublishSubject<Void>()
    let showAlertEvent = PublishSubject<Void>()
    
    var categories: [ReportCategory] = [.Spam, .Information, .Violence, .Harrassment, .Nudity, .Other]
    var selectedCategory: ReportCategory = .Spam
    var type: ReportType = .Post
    var reportedUser: String?
    var reportingUser: String?
    var post: String?
    var comment: String?
    
    
    func report() {
        guard let reportedUser = reportedUser, let reportingUser = reportingUser else {
            return
        }
        
        switch type {
        case .Post:
            if let post = post {
                let request = ReportRequest(reportingUser: reportingUser, reportedUser: reportedUser, type: type.rawValue, post: post, comment: nil, problem: selectedCategory.rawValue)
                provider
                    .report(request: request)
                    .trackActivity(self.bodyLoading)
                    .asSingle()
                    .subscribe(onSuccess: { [weak self] response in
                        guard let self = self else { return }
                        if response.success == true {
                            self.reportSuccess.onNext(())
                        }
                    }).disposed(by: disposeBag)
            }
        case .Comment:
            if let comment = comment {
                let request = ReportRequest(reportingUser: reportingUser, reportedUser: reportedUser, type: type.rawValue, post: nil, comment: comment, problem: selectedCategory.rawValue)
                provider
                    .report(request: request)
                    .trackActivity(self.bodyLoading)
                    .asSingle()
                    .subscribe(onSuccess: { [weak self] response in
                        guard let self = self else { return }
                        if response.success == true {
                            self.reportSuccess.onNext(())
                        }
                    }).disposed(by: disposeBag)
            }
        }
    }
}
