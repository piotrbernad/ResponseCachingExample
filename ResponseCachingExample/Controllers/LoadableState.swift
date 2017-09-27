//
//  LoadableState.swift
//  ResponseCachingExample
//
//  Created by Piotr Bernad on 07/09/2017.
//  Copyright © 2017 Piotr Bernad. All rights reserved.
//

import Foundation

public enum LoadableState<ItemType> {
    case idle
    case loading
    case loaded(items: [ItemType])
    case contentUnavailable
    case refreshing
    case error(error: Error)
    
    public func items() -> [ItemType]? {
        switch self {
        case .loaded(let items):
            return items
        default:
            return nil
        }
    }
    
    public func allItems() -> [ItemType]? {
        switch self {
        case .loaded(let items):
            return items
        default:
            return nil
        }
    }
    
    public var allItemsCount: Int {
        return self.allItems()?.count ?? 0
    }
}
