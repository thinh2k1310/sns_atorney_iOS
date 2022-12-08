//
//  ListAttorneyViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/8/22.
//

import Foundation
import RxSwift

final class ListAttorneyViewModel: ViewModel {
    
    let getListAttorneysSuccess = PublishSubject<[Attorney]>()
    
    var category: String?
    
    var arttorneys: [Attorney] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListAttorney()
    }
    
    
    
    private func getListAttorney() {
        guard let category = category else {
            return
        }
        provider.getAttorney(request: ListAttorneyRequest(category: category))
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    guard let attorneys = response.data else { return }
                    self.arttorneys = attorneys
                    self.getListAttorneysSuccess.onNext(attorneys)
                }
            }).disposed(by: disposeBag)
    }
}
