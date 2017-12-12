//
//  CoinStructTests.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import XCTest
@testable import Coin_Wallet

class CoinStructTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit_SetCoinWithID() {
        let coin = Coin(id: "bitcoin")
        
        XCTAssertEqual(coin.id, "bitcoin")
    }
    
    func testInit_SetCoin() {
        let coin = Coin(id: "bitcoin", name: "Bitcoin", symbol: "BTC", rank: "1", price_usd: 16753.2, last_updated: "1512995653")
        
        XCTAssertEqual(coin.id, "bitcoin")
        XCTAssertEqual(coin.name, "Bitcoin")
        XCTAssertEqual(coin.symbol, "BTC")
        XCTAssertEqual(coin.rank, "1")
        XCTAssertEqual(coin.price_usd, 16753.2)
        XCTAssertEqual(coin.last_updated, "1512995653")
    }
    
    func testCoinsAreEqual_ShouldReturnTrue() {
        let coin1 = Coin(id: "bitcoin", name: "Bitcoin", symbol: "BTC", rank: "1", price_usd: 16753.2, last_updated: "1512995653")
        let coin2 = Coin(id: "bitcoin", name: "Bitcoin", symbol: "BTC", rank: "1", price_usd: 16753.2, last_updated: "1512995653")
        
        XCTAssertEqual(coin1, coin2)
    }
    
    func testCoinIDsAreDifferent_ShouldReturnNotEqual() {
        let coin1 = Coin(id: "bitcoin")
        let coin2 = Coin(id: "ethereum")
        
        XCTAssertNotEqual(coin1, coin2)
    }
}

