//
//  Github.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 06/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import Moya

enum FakeAPITarget: TargetType, CachableTarget {
    case posts
    case comments(postId: Int)
    
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .posts:
            return "posts"
        case .comments(let postId):
            return "comments/" + String(describing: postId)
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var cachingEnabled: Bool {
        switch self {
        case .posts:
            return true
        default:
            return false
        }
    }
}
