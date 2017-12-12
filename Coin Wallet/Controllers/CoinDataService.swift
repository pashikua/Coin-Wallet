//
//  CoinDataService.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit

class CoinDataService: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var coinManager: CoinManager?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (coinManager?.coinsCount)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinTableViewCell
        
        guard let coinManager = coinManager else { fatalError() }
        
        let coin = coinManager.coinAtIndex(index: indexPath.row)
        
        cell.configCoinCell(withCoin: coin)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: show detailed view
        print("Did select row at:", indexPath.row)
    }
    

    
}
