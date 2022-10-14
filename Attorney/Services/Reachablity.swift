//
//  Reachablity.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Foundation
import Reachability
import RxSwift

// An observable that completes when the app gets online (possibly completes immediately).
func connectedToInternet() -> Observable<Bool> {
    return ReachabilityManager.shared.reach
}

func removeReachability() {
    ReachabilityManager.shared.stopNotifier()
}

func startReachability() {
    ReachabilityManager.shared.startNotifier()
}

private class ReachabilityManager: NSObject {
    static let shared = ReachabilityManager()

    let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return reachSubject.asObservable()
    }

    let reachability: Reachability? = try? Reachability()
    override init() {
        super.init()

            reachability?.whenReachable = { _ in
                DispatchQueue.main.async {
                    self.reachSubject.onNext(true)
                }
            }

            reachability?.whenUnreachable = { _ in
                DispatchQueue.main.async {
                    self.reachSubject.onNext(false)
                }
            }

            do {
                try reachability?.startNotifier()
                reachSubject.onNext(reachability?.connection != Reachability.Connection.unavailable)
            } catch {
                print("Unable to start notifier")
            }
    }

    func startNotifier() {
        do {
          try reachability?.startNotifier()
        } catch {
          print("Unable to start notifier")
        }
    }

    func stopNotifier() {
        reachability?.stopNotifier()
    }
}
