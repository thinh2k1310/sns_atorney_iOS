//
//  CaseChildViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import Foundation
import RxSwift

final class CaseChildViewModel: ViewModel {
    
    var casesToDisplay: [Case] = []
    var isLoadingCases = true
    let resetPageEvent = PublishSubject<Void>()
    let getRequestsSuccessEvent = PublishSubject<Void>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        casesToDisplay.removeAll()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        fetchCases()
    }
    
    func fetchCases() {
        resetPageEvent.onNext(())
        provider
            .getAllCase()
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                guard let cases = response.data else { return }
                strongSelf.isLoadingCases = false
                strongSelf.casesToDisplay = cases
                strongSelf.getRequestsSuccessEvent.onNext(())
            }, onFailure: { _ in
                self.isLoadingCases = false
            }).disposed(by: disposeBag)
    }

}
