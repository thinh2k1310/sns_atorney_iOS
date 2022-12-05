//
//  ChangeImageViewModel.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/5/22.
//

import UIKit
import RxSwift

final class ChangeImageViewModel: ViewModel {
    let changeImageSuccess = PublishSubject<User>()
    
    var media: UIImage?
    var imageType : ImageType = .avatar
    
    func changeImage() {
        switch imageType {
        case .avatar:
            changeAvatar()
        case .cover:
            changeCover()
        }
    }
    
    private func changeAvatar() {
        guard let media = media else {
            return
        }

        let request = ChangeAvatarRequest(media: media)
        provider
            .changeAvatar(request: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    if let user = response.data {
                        self.changeImageSuccess.onNext(user)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func changeCover() {
        guard let media = media else {
            return
        }

        let request = ChangeCoverRequest(media: media)
        provider
            .changeCover(request: request)
            .trackActivity(self.bodyLoading)
            .asSingle()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.success == true {
                    if let user = response.data {
                        self.changeImageSuccess.onNext(user)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
}

enum ImageType: String {
    case avatar = "Change Avatar"
    case cover = "Change Cover"
}

