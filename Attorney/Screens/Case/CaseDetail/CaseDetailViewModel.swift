//
//  CaseDetailViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import Foundation
import RxSwift

final class CaseDetailViewModel: ViewModel {
    let getCaseDetailSuccess = PublishSubject<Case>()
    let reloadCaseEvent = PublishSubject<Void>()
    
    var caseId: String?
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeReloadEvent()
        getCaseDetail()
    }
    
    func getCaseDetail() {
        guard let caseDetailId = caseId else {
            return
        }

        provider
            .getCaseDetail(caseId: caseDetailId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    guard let caseDetail = response.data else { return }
                    self.getCaseDetailSuccess.onNext(caseDetail)
                }
            },onFailure: { _ in 
                log.debug("Fail")
            }
            ).disposed(by: disposeBag)
    }
    
    func cancelCase() {
        guard let caseDetailId = caseId else {
            return
        }
        provider
            .cancelCase(caseId: caseDetailId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.reloadCaseEvent.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    func completeCase() {
        guard let caseDetailId = caseId else {
            return
        }
        provider
            .completeCase(caseId: caseDetailId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.reloadCaseEvent.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    private func subscribeReloadEvent(){
        reloadCaseEvent.subscribe(onNext: { [weak self] in
            self?.getCaseDetail()
        })
    }
}
