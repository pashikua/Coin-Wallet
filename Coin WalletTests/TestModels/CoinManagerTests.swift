//
//  CoinManagerTests.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import XCTest
@testable import Coin_Wallet

class CoinManagerTests: XCTestCase {
    
    var sut: CoinManager!
    
    override func setUp() {
        super.setUp()
        
        sut = CoinManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCoinsCount_ReturnsZero() {
        XCTAssertEqual(sut.coinsCount, 0)
    }
    
    func testCoinsCount_ShouldBeOneAfterCoinAdded() {
        sut.addCoinToLibrary(coin: Coin(id: "bitcoin"))
        
        XCTAssertEqual(sut.coinsCount, 1)
    }
    
    func testCoinsAtIndex_ReturnLastAddedCoin() {
        let coin = Coin(id: "bitcoin")
        sut.addCoinToLibrary(coin: Coin(id: "bitcoin"))
        
        let returnedCoinAtIndex = sut.coinAtIndex(index: 0)
        XCTAssertEqual(coin.id, returnedCoinAtIndex.id)
    }
    
    func testCoinCount_ShouldRemoveCoinFromCoinsArray() {
        sut.addCoinToLibrary(coin: Coin(id: "bitcoin"))
        sut.addCoinToLibrary(coin: Coin(id: "ethereum"))
        sut.removeCoinFromLibrary(index: 0)
        
        XCTAssertEqual(sut.coinsCount, 1)
    }
    
    func testClearAllArrayItems_ShouldReturnArrayCountOfZero() {
        sut.addCoinToLibrary(coin: Coin(id: "bitcoin"))
        sut.addCoinToLibrary(coin: Coin(id: "ethereum"))
        sut.clearArray()
        
        XCTAssertEqual(sut.coinsCount, 0)
    }
}
