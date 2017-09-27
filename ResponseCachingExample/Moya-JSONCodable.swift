//
//  Moya-JSONCodable.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 06/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import Moya
import JSONCodable
import RxSwift

public extension Response {
    public func mapToObject<T:JSONDecodable>() throws -> T {
        let json = try self.mapJSON() as? JSONObject ?? [:]
        
        let result = try T(object: json)
        
        return result
    }
    
    public func mapToArray<T:JSONDecodable>() throws -> [T] {
        let json = try self.mapJSON() as? [JSONObject] ?? []
        
        let result: [T] = try Array<T>(JSONArray: json)

        return result
    }
}

public extension ObservableType where E == Moya.Response {
    public func mapObject<T: JSONDecodable>() -> Observable<T> {
        
        return Observable.create { observer in
            
            self.subscribe { event in
                switch event {
                case .next(let response):
                    do {
                        let object: T = try response.mapToObject()
                        observer.onNext(object)
                    } catch let error {
                        observer.onError(error)
                    }
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            }
        }
    }
    
    public func mapObject<T: JSONDecodable>() -> Observable<[T]> {
        
        return Observable.create { observer in
            self.subscribe { event in
                
                switch event {
                case .next(let response):
                    do {
                        let object: Array<T> = try response.mapToArray()
                        observer.onNext(object)
                    } catch let error {
                        observer.onError(error)
                    }
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            }
        }
    }
}
