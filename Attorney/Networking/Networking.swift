//
//  Networking.swift
//  Attorney
//
//  Created by Truong Thinh on 10/10/2022.
//

import Alamofire
import Foundation
import JWTDecode
import Moya
import RxCocoa
import RxSwift

struct OnlineProvider<Target> where Target: Moya.TargetType {
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    let stubbingProvider = MoyaProvider<Target>(stubClosure: MoyaProvider.immediatelyStub)

    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
         session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false,
         isTrustServer: Bool = true,
         online: Observable<Bool> = connectedToInternet()) {
        self.online = online

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        var trustManager: ServerTrustManager?
        if let baseURL = (Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String) {
            let url = URL(string: baseURL)
            trustManager = ServerTrustManager(evaluators: [url?.host ?? "": PublicKeysTrustEvaluator()])
        }
        let serverTrustManager = isTrustServer ? trustManager : nil
        let pinnedSession = Session(configuration: configuration,
                                    startRequestsImmediately: true,
                                    serverTrustManager: serverTrustManager)
        
        self.provider = MoyaProvider(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, session: pinnedSession, plugins: plugins, trackInflights: trackInflights)
    }
}

protocol NetworkingType {
    associatedtype T: TargetType
    var provider: OnlineProvider<T> { get }
}

struct AttorneyNetworking: NetworkingType {
    typealias T = AttorneySNSAPI
    let provider: OnlineProvider<AttorneySNSAPI>
}

extension NetworkingType {
    static func attorneyNetworking() -> AttorneyNetworking {
        return AttorneyNetworking(provider: OnlineProvider(endpointClosure: endpointsClosure(), requestClosure: AttorneyNetworking.endpointResolver(), plugins: plugins, online: .just(true)))
    }
    
    static func endpointsClosure<T>(_ xAccessToken: String? = nil) -> (T) -> Endpoint where T: TargetType {
        return { target in
            let endpoint = MoyaProvider.defaultEndpointMapping(for: target)

            // Sign all non-XApp, non-XAuth token requests
            return endpoint
        }
    }

    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        return .never
    }

    static var plugins: [PluginType] {
        var plugins: [PluginType] = []
        if Configurations.Network.loggingEnabled == true {
            let plugin: PluginType = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            plugins.append(plugin)
        }
        return plugins
    }
    
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch let error as MoyaError {
                closure(.failure(error))
            } catch {
                log.error(error.localizedDescription)
            }
        }
    }
}
