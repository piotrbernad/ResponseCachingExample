//
//  Comment.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 06/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import JSONCodable

struct Comment {
    let id: Int
    let postId: Int
    let body: String
    let name: String
}

extension Comment: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        postId = try decoder.decode("postId")
        body = try decoder.decode("body")
        name = try decoder.decode("name")
    }
}
