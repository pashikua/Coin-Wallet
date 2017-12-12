//
//  Coin.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation

struct Coin: Equatable, Codable {
    static func ==(lhs: Coin, rhs: Coin) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        
        if lhs.rank != rhs.rank {
            return false
        }
        
        return true
    }
    
    
    let id: String
    let name: String?
    let symbol: String?
    var rank: Int?
    var price_usd: Float?
    var last_updated: String?
    var holding: Float?
    
    init(id: String,
         name: String? = nil,
         symbol: String? = nil,
         rank: Int? = nil,
         price_usd: Float? = nil,
         last_updated: String? = nil,
         holding: Float? = nil) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.rank = rank
        self.price_usd = price_usd
        self.last_updated = last_updated
        self.holding = holding
    }
}
