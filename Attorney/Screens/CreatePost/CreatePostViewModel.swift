//
//  CreatePostViewModel.swift
//  Attorney
//
//  Created by Truong Thinh on 01/12/2022.
//

import Foundation
import RxSwift
import UIKit

final class CreatePostViewModel: ViewModel {
    let createPostSuccess = PublishSubject<Void>()
    
    var type: String = PostType.DISCUSSING.rawValue
    var media: UIImage?
    var content: String = ""
    
    func createPost() {
        let request = CreatePostRequest(content: content, type: type, media: media)
        provider
            .createPost(createPostRequest: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    self.createPostSuccess.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
}
