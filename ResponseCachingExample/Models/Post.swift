//
//  User.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 06/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation
import JSONCodable

struct Post {
    let id: Int
    let title: String
}

extension Post: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        title = try decoder.decode("title")
    }
}
