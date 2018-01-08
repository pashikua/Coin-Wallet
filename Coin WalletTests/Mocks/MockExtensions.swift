//
//  MockExtensions.swift
//  Coin WalletTests
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation
import UIKit
@testable import Coin_Wallet

extension CoinDataServiceTests {
    class TableViewMock: UITableView {
        var cellDequeuedProperly: Bool = false
        
        override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
            cellDequeuedProperly = true
            
            return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        class func initializeTableViewMock() -> TableViewMock {
            let tableViewMock = TableViewMock(frame: CGRect.init(x: 0, y: 0, width: 300, height: 500), style: .plain)
            tableViewMock.register(CoinCellMock.self, forCellReuseIdentifier: "coinCell")
            return tableViewMock
        }
    }
    
    class CoinCellMock: CoinTableViewCell {
        var coin: Coin?
        
        func configCoinCell(withCoin: Coin) {
            coin = withCoin
        }
    }
}

extension CoinTableViewCellTests {
    class MockCellDataSource: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}
