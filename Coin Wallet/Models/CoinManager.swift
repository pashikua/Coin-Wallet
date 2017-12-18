//
//  CoinManager.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate: class {
    func updatePortfolioValue(_ coinsLibrary: [Coin])
}

class CoinManager {
    
    weak var delegate: CoinManagerDelegate?
    
    var coinsCount: Int { return coinsLibrary.count }
    
    private var coinsLibrary = [Coin]()
    
    func addCoinToLibrary(coin: Coin) {
        coinsLibrary.append(coin)
    }
    
    func coinAtIndex(index: Int) -> Coin {
        return coinsLibrary[index]
    }
    
    func updateCoinAtIndexAndSaveToDisk(index: Int, holding: Float) {
        coinsLibrary[index].holding = holding
        
        _ = CoinHandler.updateCoinsDataOnDisk(coins: coinsLibrary)
        // Update Portfolio Label Value
        delegate?.updatePortfolioValue(coinsLibrary)
    }
    
    func removeCoinFromLibrary(index: Int) {
        coinsLibrary.remove(at: index)
        
        _ = CoinHandler.updateCoinsDataOnDisk(coins: coinsLibrary)
        // Update Portfolio Label Value
        delegate?.updatePortfolioValue(coinsLibrary)
    }
    
    func clearArray() {
        coinsLibrary.removeAll()
    }
}
