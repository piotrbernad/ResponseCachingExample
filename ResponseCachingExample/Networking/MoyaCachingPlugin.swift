//
//  MoyaCachingPlugin.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 17/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import Moya
import Result
import JSONCodable
import RxSwift

extension CachableTarget where Self: TargetType {
    var cacheKey: String {
        return self.path
    }
}

public protocol CachableTarget {
    var cachingEnabled: Bool { get }
    var cacheKey: String { get }
}

struct CachingPlugin: Moya.PluginType {
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard let cachableTarget = target as? CachableTarget else {
            return
        }
        
        guard cachableTarget.cachingEnabled else { return }
        
        
        _ = result.analysis(ifSuccess: { (response) -> Result<Response, MoyaError> in
            
            guard let json = try? response.mapString() else {
                assertionFailure("Could not map response to json")
                return result
            }
            
            guard let data = json.data(using: .utf8) else {
                assertionFailure("could not transform json to data")
                return result
            }
            
            storeJSON(json: data, target: cachableTarget)
            
            return result
        }) { (error) -> Result<Response, MoyaError> in
            return result
        }
    }
    
    private func storeJSON(json: Data, target: CachableTarget) {
        let storage = CacheStorage(cacheKey: target.cacheKey)
        
        storage.write(json)
        
    }
}

public class CacheStorage {
    
    private let cacheKey: String
  
    fileprivate lazy var storeUrl: URL? = {
        guard let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assertionFailure("could not find storage path")
            return nil
        }
        
        return dir.appendingPathComponent(self.cacheKey)
    }()
    

    public init(cacheKey: String) {

        self.cacheKey = cacheKey
    }

    public func write(_ data: Data) {
        guard let storeUrl = self.storeUrl else {
            assertionFailure("Could not create store url")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            try? data.write(to: storeUrl)
        }
    }
    
    public func read() -> Data? {
        guard let storeUrl = self.storeUrl else {
            assertionFailure("Could not create store url")
            return nil
        }
        
        let readData = try? Data(contentsOf: storeUrl)
        return readData
    }
    
    
    public func read<T: JSONDecodable>() -> T? {
        guard let data = self.read() else { return nil }
        
        guard let jsonString = String(bytes: data, encoding: .utf8) else { return nil }
        
        return try? T(JSONString: jsonString)
    }
    
    public func read<T: JSONDecodable>() -> [T]? {
        guard let data = self.read() else { return nil }
        
        guard let jsonString = String(bytes: data, encoding: .utf8) else { return nil }
        
        return try? Array<T>(JSONString: jsonString)
    }
}
