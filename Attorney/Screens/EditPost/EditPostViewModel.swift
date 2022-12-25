//
//  EditPostViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/26/22.
//

import Foundation
import RxSwift
import UIKit

final class EditPostViewModel: ViewModel {
    let editPostSuccess = PublishSubject<Void>()
    
    var content: String = ""
    var postId: String?
    
    func editPost() {
        guard let postId = postId else {
            return
        }

        
        let request = EditPostRequest(id: postId, content: content)
        provider
            .editPost(editPostRequest: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.editPostSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
}
