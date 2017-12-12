//
//  MainViewControllerTests.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import XCTest
@testable import Coin_Wallet

class MainViewControllerTests: XCTestCase {
    
    var sut: MainViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        _ = sut.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testMainVC_TableViewShouldBeNotNil() {
        XCTAssertNotNil(sut.coinTableView)
    }
    
    
    func testViewDidLoad_SetsTableViewDataSource() {
        XCTAssertNotNil(sut.coinTableView.dataSource)
        XCTAssertTrue(sut.coinTableView.dataSource is CoinDataService)
    }
    
    func testViewDidLoad_SetsTableViewDelegate() {
        XCTAssertNotNil(sut.coinTableView.delegate)
        XCTAssertTrue(sut.coinTableView.delegate is CoinDataService)
    }
    
    func testViewDidLoad_SetsTableViewDelegateAndDataSourceToSameObject() {
        XCTAssertEqual(sut.coinTableView.delegate as! CoinDataService, sut.coinTableView.dataSource as! CoinDataService)
    }
}
