//
//  ReviewViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import Foundation
import RxSwift

final class ReviewViewModel: ViewModel {
    let postReviewSuccess = PublishSubject<Void>()
    
    var caseId: String?
    
    func postReview(rating: Int, content: String) {
        guard let caseId = caseId else {
            return
        }

        let request = ReviewRequest(cases: caseId, point: rating, content: content)
        provider.postReview(request: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.postReviewSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
}
