//
//  CoinManager.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation

class CoinManager {
    
    var coinsCount: Int { return coinsLibrary.count }
    
    private var coinsLibrary = [Coin]()
    
    func addCoinToLibrary(coin: Coin) {
        coinsLibrary.append(coin)
    }
    
    func coinAtIndex(index: Int) -> Coin {
        return coinsLibrary[index]
    }
    
    func removeCoinFromLibrary(index: Int) {
        coinsLibrary.remove(at: index)
        
        _ = CoinHandler.updateCoinsDataOnDisk(coins: coinsLibrary)
    }
    
    func clearArray() {
        coinsLibrary.removeAll()
    }
}
