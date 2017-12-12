//
//  CoinDataServiceTests.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import XCTest
@testable import Coin_Wallet

class CoinDataServiceTests: XCTestCase {
    
    var sut: CoinDataService!
    var tableView: UITableView!
    var mainVC: MainViewController!
    
    override func setUp() {
        super.setUp()
        
        sut = CoinDataService()
        sut.coinManager = CoinManager()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        _ = mainVC.view
        
        tableView = mainVC.coinTableView
        tableView.dataSource = sut
        tableView.delegate = sut
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTableViewRowsCount_ShouldBeThree() {
        let rowsCount = tableView.numberOfRows(inSection: 0)
        debugPrint(rowsCount)
        XCTAssertEqual(rowsCount, sut.coinManager?.coinsCount)
    }
    
    func testCellForRowAtIndex_ShouldReturnCoinCell() {
        sut.coinManager?.addCoinToLibrary(coin: Coin(id: "bitcoin"))
        tableView.reloadData()
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell is CoinTableViewCell)
    }
    
    
    func testCellConfig_ShouldSetCellData() {
        let tableViewMock = TableViewMock.initializeTableViewMock()
        tableViewMock.dataSource = sut
        
        let coin = Coin(id: "bitcoin")
        sut.coinManager?.addCoinToLibrary(coin: coin)
        tableViewMock.reloadData()
        
        let cell = tableViewMock.cellForRow(at: IndexPath(row: 0, section: 0)) as! CoinCellMock
        
        XCTAssertEqual(cell.coin, coin)
    }
}
