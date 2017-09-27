//
//  API.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 06/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import JSONCodable

public struct API<T: TargetType> {

    fileprivate var provider: RxMoyaProvider<T> = RxMoyaProvider(plugins: [CachingPlugin()], trackInflights: true)
    
    private func request(_ endpoint: T) -> Observable<Response> {
        return provider.request(endpoint).asObservable()
    }

    public func request<O: JSONDecodable>(_ endpoint: T) -> Observable<O> {
        return provider.request(endpoint).asObservable().mapObject()
    }
    
    public func request<O: JSONDecodable>(_ endpoint: T) -> Observable<[O]> {
        return provider.request(endpoint).asObservable().mapObject()
    }
}

extension API where T: CachableTarget {
    
    public func provide<O: JSONDecodable>(_ endpoint: T) -> Observable<O> {
        let network: Observable<O> = self.request(endpoint)
        
        return self.cache(endpoint)
            .concat(network)
    }
    
    public func provide<O: JSONDecodable>(_ endpoint: T) -> Observable<[O]> {
        let network: Observable<[O]> = self.request(endpoint)
        
        return self.cache(endpoint)
            .concat(network)
    }
    
    public func cache<O: JSONDecodable>(_ endpoint: T) -> Observable<[O]> {
        let cache = CacheStorage(cacheKey: endpoint.cacheKey)
        
        guard let readObject: [O] = cache.read() else {
            return Observable.empty()
        }
        
        return Observable.just(readObject)
    }
    
    public func cache<O: JSONDecodable>(_ endpoint: T) -> Observable<O> {
        let cache = CacheStorage(cacheKey: endpoint.cacheKey)
        
        guard let readObject: O = cache.read() else {
            return Observable.empty()
        }
        
        return Observable.just(readObject)
    }
}

struct FakeAPI {
    static let api = API<FakeAPITarget>()
    
    static func allPosts() -> Observable<[Post]> {
        return api.provide(.posts)
    }
    
    static func postComments(_ postId: Int) -> Observable<[Comment]> {
        return api.provide(.comments(postId: postId))
    }
}
