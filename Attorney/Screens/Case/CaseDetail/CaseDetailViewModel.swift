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
    let caseCommentsEvent = PublishSubject<[CaseComment]>()
    let addCommentSuccess = PublishSubject<Void>()
    let deleteCommentSuccess = PublishSubject<Void>()
    let reloadComment = PublishSubject<Void>()
    
    var caseId: String?
    var comments: [CaseComment] = []
    var cases: Case?
    
    override init(provider: AttorneyAPI) {
        super.init(provider: provider)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeReloadEvent()
        subcribeReloadComment()
        getCaseDetail()
        getCaseComments()
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
                    self.cases = caseDetail
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
            }, onFailure: { [weak self] _ in
                self?.reloadCaseEvent.onNext(())
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
            }, onFailure: { [weak self] _ in
                self?.reloadCaseEvent.onNext(())
            }).disposed(by: disposeBag)
    }
    
    func getCaseComments() {
        guard let caseId = caseId else {
            return
        }
        
        provider.getCaseComments(caseId: caseId)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    guard let comments = response.data else { return }
                    self.comments = comments
                    self.caseCommentsEvent.onNext(comments)
                }
            }).disposed(by: disposeBag)
    }
    
    func commentCase(caseId: String, content: String) {
        guard let userInfo : UserInfo = UserDefaults.standard.retrieveObject(forKey: UserKey.kUserInfo),
        let userId = userInfo.id else {
           return
        }
        provider
            .commentCase(commentRequest: CaseCommentRequest(userId: userId, caseId: caseId, content: content))
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success {
                    if success {
                        self.addCommentSuccess.onNext(())
                    }
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
    }
    
    func deleteComment(commentId: String) {
        provider.deleteCaseComment(commentId: commentId)
            .subscribe { [weak self] (response) in
                guard let self = self else { return }
                if let success = response.success {
                    if success {
                        self.deleteCommentSuccess.onNext(())
                    }
                }
            } onFailure: { (_) in
                print("fetch news feed failed")
            }.disposed(by: disposeBag)
    }
    
    private func subscribeReloadEvent(){
        reloadCaseEvent.subscribe(onNext: { [weak self] in
            self?.getCaseDetail()
        }).disposed(by: disposeBag)
    }
    
    private func subcribeReloadComment() {
        addCommentSuccess.subscribe(onNext: { [weak self] in
            self?.getCaseComments()
            self?.reloadComment.onNext(())
        }).disposed(by: disposeBag)
        
        deleteCommentSuccess.subscribe(onNext: { [weak self] in
            self?.getCaseComments()
        }).disposed(by: disposeBag)
    }
    
    func sizeForHeaderView() -> CGFloat {
        guard let cases = cases else { return 0}
        let width = UIScreen.main.bounds.width
        let textviewHeight = (cases.post?.content ?? "").heightAsLabel(withConstrainedWidth: width - 20, font: UIFont.appFont(size: 14), numberOfLines: 3)
        return (textviewHeight + 610)
    }
    
    func cellSizeForComment(at index: Int) -> CGFloat {
        guard !comments.isEmpty else { return 0}
        let width = UIScreen.main.bounds.width
        let comment = comments[index]
        let contentHeight = (comment.content ?? "").heightAsLabel(withConstrainedWidth: width - 96, font: UIFont.appFont(size: 14), numberOfLines: 0)
        return (contentHeight + 24 + 12 + 21 + 15)
    }
}

