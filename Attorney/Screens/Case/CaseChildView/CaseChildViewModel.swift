//
//  CaseChildViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 02/12/2022.
//

import Foundation
import RxSwift

final class CaseChildViewModel: ViewModel {
    
    var inProgressCases: [Case] = []
    var completedCases: [Case] = []
    var cancelledCases: [Case] = []
    var isLoadingCases = true
    let resetPageEvent = PublishSubject<Void>()
    let getRequestsSuccessEvent = PublishSubject<Void>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        inProgressCases.removeAll()
        completedCases.removeAll()
        cancelledCases.removeAll()
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
                guard let progress = response.inProgressCases,
                      let cancel = response.cancelledCases,
                      let completed = response.completedCases else { return }
                strongSelf.isLoadingCases = false
                strongSelf.inProgressCases = progress
                strongSelf.completedCases = completed
                strongSelf.cancelledCases = cancel
                strongSelf.getRequestsSuccessEvent.onNext(())
            }, onFailure: { _ in
                self.isLoadingCases = false
            }).disposed(by: disposeBag)
    }
    
    func isEmpty() -> Bool {
        return inProgressCases.isEmpty && completedCases.isEmpty && cancelledCases.isEmpty
    }
    
    func allCases() -> Int {
        return inProgressCases.count + completedCases.count + cancelledCases.count
    }

}
