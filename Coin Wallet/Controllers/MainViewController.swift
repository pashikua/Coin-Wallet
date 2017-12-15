//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import Disk
import SwiftyJSON

class MainViewController: UIViewController {
    
    @IBOutlet weak var coinTableView: UITableView!
    @IBOutlet var dataService: CoinDataService!

    @IBOutlet weak var totalPortfolioValue: UILabel!
    
    var coinManager: CoinManager = CoinManager()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coinTableView.refreshControl = refreshControl
        self.coinTableView.dataSource = dataService
        self.coinTableView.delegate = dataService
        dataService.coinManager = coinManager
        
        // Configure Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)
        
//        clearDiskDataFromCaches()
        self.view.layoutIfNeeded()
        refreshCoinData(refreshControl)
        
        fetchCoinsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        updateTableViewFromDisk()
    }

    
    @IBAction func addCoinBtnPressed(_ sender: Any) {
//        _ = CoinHandler.getCoinsData(completion: { (coins) in
//            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddCoinVC") as? AddCoinViewController {
//                vc.pickerData = coins
//
//                DispatchQueue.main.async {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//        })
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddCoinVC") as? AddCoinViewController {
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func refreshCoinData(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        print("refreshCoinDataTriggered")
        if dataService.coinManager?.coinsCount != nil {
            _ = CoinHandler.getCoinsData(completion: { (coins) in
                do {
                    self.dataService.coinManager?.clearArray()
                    
                    var retrievedCoins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
                    
                    
                    for (index, oldCoin) in retrievedCoins.enumerated() {
                        for newCoin in coins {
                            if oldCoin.id == newCoin.id {
                                retrievedCoins[index].price_usd = newCoin.price_usd
                                retrievedCoins[index].rank = newCoin.rank
                                retrievedCoins[index].last_updated = newCoin.last_updated
                            }
                        }
                    }
                    
                    self.updateTotalPortfolioLabel(coinsArray: retrievedCoins)
                    
                    for coin in retrievedCoins.sorted(by: {$0.rank! < $1.rank!}) {
                        self.dataService.coinManager?.addCoinToLibrary(coin: coin)
                    }
                    print(retrievedCoins)
                    
                    DispatchQueue.main.async {
                        self.coinTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.clearAndUpdateCoinDiskData(coins: retrievedCoins)
                } catch {
                    print("Couldnt retrieve coin")
                    self.endRefresh()
                }
            })
        } else {
            print("coinscount == nil")
            self.endRefresh()
        }
    }
    
    func fetchCoinsData() {
        print("2")
        _ = CoinHandler.getCoinsData(completion: { (coins) in
            do {

                if Disk.exists("coinsData.json", in: .caches) {
                    print("coins data exits in cache")
                    try Disk.remove("coinsData.json", from: .caches)
                }
                
                for coin in coins {
                    try Disk.append(coin, to: "coinsData.json", in: .caches)
                }
            } catch {
                print("Coudlnt save to disk")
            }
        })
    }
    
    func updateTableViewFromDisk() {
        print("1")
        dataService.coinManager?.clearArray()
        
        do {
            let retrievedCoins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
            
            for coin in retrievedCoins.sorted(by: {$0.rank! < $1.rank!}) {
                dataService.coinManager?.addCoinToLibrary(coin: coin)
            }
            print(retrievedCoins)
            updateTotalPortfolioLabel(coinsArray: retrievedCoins)
        } catch {
            print("Couldnt retrieve coin")
            endRefresh()
        }
        
        self.coinTableView.reloadData()
    }
    
    func updateTotalPortfolioLabel(coinsArray: [Coin]) {
        var coinValues: [CGFloat] = []
        
        for coin in coinsArray {
            // Multiply coin holding with current price of coin
            let value = CGFloat(coin.holding!) * CGFloat(coin.price_usd!)
            
            coinValues.append(value)
        }
        
        DispatchQueue.main.async {
            self.totalPortfolioValue.text = String(format: "%.2f", coinValues.reduce(0, +))
        }
    }
    
    func endRefresh() {
        DispatchQueue.main.async {
            self.coinTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func clearAndUpdateCoinDiskData(coins: [Coin]) {
        do {
            if Disk.exists("coins.json", in: .caches) {
                print("coins exits in cache")
                try Disk.remove("coins.json", from: .caches)
            }
            
            for coin in coins {
                do {
                    try Disk.append(coin, to: "coins.json", in: .caches)
                } catch {
                    print("Coudlnt save to disk")
                }
            }
        } catch {
            print("Couldnt clear disk")
        }
    }
    
}

