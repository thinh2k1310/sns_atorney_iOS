//
//  ViewReviewViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/13/22.
//

import Foundation
import RxSwift

final class ViewReviewViewModel: ViewModel {
    
    let getReviewsDone = PublishSubject<Void>()
    
    var reviews: [Review] = []
    var attorneyId: String?
    var rating: Float = 0
    var total: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviews()
    }
    
    func getReviews() {
        guard let attorneyId = attorneyId else {
            return
        }
        
        provider
            .getAttorneyReview(attorneyId: attorneyId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success {
                    if success {
                        self.rating = response.rating ?? 0
                        self.total = response.total ?? 0
                        self.reviews = response.reviews ?? []
                        self.getReviewsDone.onNext(())
                    }
                }
            }).disposed(by: disposeBag)
    }
    
}
