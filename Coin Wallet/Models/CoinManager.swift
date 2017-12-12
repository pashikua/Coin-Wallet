//
//  CoinManager.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation

class CoinManager {
    
    var coinsCount: Int { return coinsArray.count }
    
    private var coinsArray = [Coin]()
    
    func addCoinToLibrary(coin: Coin) {
        coinsArray.append(coin)
    }
    
    func coinAtIndex(index: Int) -> Coin {
        return coinsArray[index]
    }
    
    func removeCoinFromLibrary(index: Int) {
        coinsArray.remove(at: index)
    }
    
    func clearArray() {
        coinsArray.removeAll()
    }
}
