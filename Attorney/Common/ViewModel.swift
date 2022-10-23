//
//  ViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 01/10/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

class ViewModel: NSObject {
    let disposeBag = DisposeBag()
    let provider: AttorneyAPI
    let bodyLoading = ActivityIndicator()
    let error = ErrorTracker()
    public let pushViewControllerSuccess = PublishSubject<Void>()

    init(provider: AttorneyAPI) {
        self.provider = provider
        super.init()
        error.asDriver()
            .drive(onNext: { (error) in
                log.error("\(error)")
            })
            .disposed(by: disposeBag)
    }

    deinit {
        log.info("deinit: \(self)")
    }

    func setupData() {
    }

    func viewDidLoad() {
    }

    func viewWillAppear() {
    }

}
