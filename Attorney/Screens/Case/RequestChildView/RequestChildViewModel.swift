//
//  RequestChildViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 03/12/2022.
//

import Foundation
import RxSwift

final class RequestChildViewModel: ViewModel {
    
    var requestsToDisplay: [Case] = []
    var isLoadingRequests = true
    let resetPageEvent = PublishSubject<Void>()
    let getRequestsSuccessEvent = PublishSubject<Void>()
    let updateRequestSuccess = PublishSubject<Void>()
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestsToDisplay.removeAll()
        subscribeEvents()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        fetchRequest()
    }
    
    func fetchRequest() {
        resetPageEvent.onNext(())
        provider
            .getDefenceRequest()
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                guard let cases = response.data else { return }
                strongSelf.isLoadingRequests = false
                strongSelf.requestsToDisplay = cases
                strongSelf.getRequestsSuccessEvent.onNext(())
            }, onFailure: { _ in
                self.isLoadingRequests = false
            }).disposed(by: disposeBag)
    }
    
    func acceptRequest(requestId: String) {
        provider
            .acceptDefenceRequest(requestId: requestId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                guard let success = response.success else { return }
                if success {
                    strongSelf.updateRequestSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    func cancelRequest(requestId: String) {
        provider
            .denyDefenceRequest(requestId: requestId)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                guard let success = response.success else { return }
                if success {
                    strongSelf.updateRequestSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    private func subscribeEvents() {
        updateRequestSuccess
            .subscribe(onNext: { [weak self] in
                self?.fetchRequest()
            }).disposed(by: disposeBag)
    }
}
