//
//  EditCommentViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/25/22.
//

import Foundation
import RxSwift
import UIKit

final class EditCommentViewModel: ViewModel {
    let editCommentSuccess = PublishSubject<Void>()
    
    var content: String = ""
    var commentId: String?
    
    func editComment() {
        guard let commentId = commentId else {
            return
        }

        let request = EditCommentRequest(id: commentId, content: content)
        provider
            .editComment(editCmtRequest: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.editCommentSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
}
