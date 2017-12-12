//
//  CoinTableViewCellTests.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import XCTest
@testable import Coin_Wallet

class CoinTableViewCellTests: XCTestCase {
    
    var tableView: UITableView!
    var dataSource: MockCellDataSource!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        _ = mainVC.view
        
        tableView = mainVC.coinTableView
        dataSource = MockCellDataSource()
        tableView.dataSource = dataSource
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCellConfig_ShouldSetLabelsToCoinData() {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: IndexPath(row: 0, section: 0)) as! CoinTableViewCell
        
        cell.configCoinCell(withCoin: Coin(id: "ethereum", symbol: "ETH"))
        
        XCTAssertEqual(cell.symbolLabel.text, "ETH")
    }
}
