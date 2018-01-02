//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import Disk
import SwiftyJSON

class MainViewController: UIViewController {
    
    @IBOutlet weak var coinTableView: UITableView!
    @IBOutlet var dataService: CoinDataService!

    @IBOutlet weak var totalPortfolioValueLabel: UILabel!
    
    var coinManager: CoinManager = CoinManager()
    
    private let refreshControl = UIRefreshControl()
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coinTableView.refreshControl = refreshControl
        self.coinTableView.dataSource = dataService
        self.coinTableView.delegate = dataService
        
        self.dataService.coinManager = coinManager
        self.dataService.coinManager?.delegate = self
        
        // Configure Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)
        
//        clearDiskDataFromCaches()
        self.view.layoutIfNeeded()
        refreshCoinData(refreshControl)
        
        fetchCoinsData()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        addBlurEffectView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        updateTableViewFromDisk()
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
                print("coinsData")
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
//            print(retrievedCoins)
            updateTotalPortfolioLabel(coinsArray: retrievedCoins)
        } catch {
            print("Couldnt retrieve coin")
            endRefresh()
        }
        
        self.coinTableView.reloadData()
    }
    
    func updateTotalPortfolioLabel(coinsArray: [Coin]) {
        var coinValues: [Float] = []
        
        for coin in coinsArray {
            // Multiply coin holding with current price of coin
            let value = Float(coin.holding!) * Float(coin.price_usd!)
            
            coinValues.append(value)
        }
        
        totalPortfolioValueAsDollar(coinValues: coinValues)
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
    
    func totalPortfolioValueAsDollar(coinValues: [Float]) {
        DispatchQueue.main.async {
            let total = coinValues.reduce(0, +)
            UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.setValue(total, forKey: "totalPortfolioValue")
            self.totalPortfolioValueLabel.text = total.changeToDollarCurrencyString()
        }
    }
    
    
}

extension MainViewController {
    // Mark: - BlurEffect

    // Blur main view while app is in background
    func addBlurEffectView() {
        // Add Blur Effect to view
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.0
        self.view.addSubview(blurEffectView)
    }
    
    func hideVisualEffectView(_ visualEffectView: UIVisualEffectView, isHidden: Bool) {
        UIView.animate(withDuration: 0.15, animations: {
            visualEffectView.alpha = isHidden ? 0.0 : 1.0
        }, completion: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        if UserDefaults.standard.bool(forKey: "isTouchIDEnabled") {
            // Show blur
            hideVisualEffectView(blurEffectView, isHidden: false)
        }
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        if UserDefaults.standard.bool(forKey: "isTouchIDEnabled") {
            // Hide blur
            hideVisualEffectView(blurEffectView, isHidden: true)
        }
    }
}

extension MainViewController: CoinManagerDelegate {
    func updatePortfolioValue(_ coinsLibrary: [Coin]) {
        var coinValues: [Float] = []
        
        for coin in coinsLibrary {
            // Multiply coin holding with current price of coin
            let value = Float(coin.holding!) * Float(coin.price_usd!)
            
            coinValues.append(value)
        }
        
        totalPortfolioValueAsDollar(coinValues: coinValues)
    }
}

