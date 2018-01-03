//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import Disk
import SwiftyJSON
import RealmSwift
import PKHUD

class MainViewController: UIViewController {
    
    @IBOutlet weak var coinTableView: UITableView!
    @IBOutlet var dataService: CoinDataService!

    @IBOutlet weak var totalPortfolioValueLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    
    var blurEffectView: UIVisualEffectView!
    
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Disk.exists("coins.json", in: .caches) {
            print("found coins.json")
            switchToRealmDatabase()
        }
        
        self.coinTableView.refreshControl = refreshControl
        self.coinTableView.dataSource = dataService
        self.coinTableView.delegate = dataService
        
//        self.dataService.realmManager = RealmManager.sharedInstance
        // TODO: DELEGATE
        RealmManager.sharedInstance.delegate = self
        
        // Configure Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)
        
//        clearDiskDataFromCaches()
        self.view.layoutIfNeeded()
        
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        addBlurEffectView()
        
        
    }
    
    func switchToRealmDatabase() {
        do {
            DispatchQueue.main.async {
                HUD.show(.label("Switching to Realm Database..."))
            }
            
            print("coins exits in cache")
            let retrievedCoins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
            
//            for coin in retrievedCoins.sorted(by: {$0.rank! < $1.rank!}) {
//                dataService.coinManager?.addCoinToLibrary(coin: coin)
//            }
            
            realm = try! Realm()
            try realm.write {
                for coin in retrievedCoins {
                    let portfolio = RLMPortfolio()
                    portfolio.id = coin.id
                    portfolio.holding = coin.holding!
                    realm.add(portfolio, update: true)
                    RealmManager.sharedInstance.addPortfolioObject(object: portfolio)
                }
            }
            
            DispatchQueue.main.async {
                HUD.hide()
            }
            // TODO: Remove old disk json files
        } catch {
            print("Couldnt retrieve coin")
            endRefresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        refreshCoinData(refreshControl)
    }
    
    @objc func refreshCoinData(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        print("refreshCoinDataTriggered")
        if RealmManager.sharedInstance.coinsCount != nil {
            _ = CoinHandler.fetchCoinsData(completion: { (success) in
                print("fetch coins data success: ", success)
//                do {
//                    self.dataService.coinManager?.clearArray()
                    
//                    var retrievedCoins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
//
//                    for (index, oldCoin) in retrievedCoins.enumerated() {
//                        for newCoin in coins {
//                            if oldCoin.id == newCoin.id {
//                                retrievedCoins[index].price_usd = newCoin.price_usd
//                                retrievedCoins[index].rank = newCoin.rank
//                                retrievedCoins[index].last_updated = newCoin.last_updated
//                            }
//                        }
//                    }
                    
//                    self.updateTotalPortfolioLabel(coinsArray: retrievedCoins)
//
//                let realm = try! Realm()
//
//                for coin in realm.objects(RLMPortfolio.self).sorted(byKeyPath: "rank").toArray(ofType: RLMPortfolio.self) {
//                    print(coin)
////                        self.dataService.realmManager?.addToPortfolioCoinArray(coin: coin)
//                }
//                    print(retrievedCoins)
                if success {
                    DispatchQueue.main.async {
                        RealmManager.sharedInstance.updatePortfolioCoinArray()
                        self.coinTableView.reloadData()
                        self.updateTotalPortfolioLabel(coinsArray: RealmManager.sharedInstance.getPortfolioCoinsArray())
                        self.refreshControl.endRefreshing()
                    }
                }
//                } catch {
//                    print("Couldnt retrieve coin")
//                    self.endRefresh()
//                }
            })
        } else {
            print("coinscount == nil")
            self.endRefresh()
        }
    }
    
    func updateTotalPortfolioLabel(coinsArray: [RLMPortfolio]) {
        var coinValues: [Float] = []
        
        for coin in coinsArray {
            // Multiply coin holding with current price of coin
            let value = Float(coin.holding) * Float(coin.priceUSD)
            
            coinValues.append(value)
        }
        
        totalPortfolioValueAsDollar(coinValues: coinValues)
    }
    
    func endRefresh() {
        DispatchQueue.main.async {
//            self.coinTableView.reloadData()
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

extension MainViewController: RealmManagerDelegate {
    func updatePortfolioValue(_ coinsPortfolio: [RLMPortfolio]) {
        var coinValues: [Float] = []
        
        for coin in coinsPortfolio {
            // Multiply coin holding with current price of coin
            let value = Float(coin.holding) * Float(coin.priceUSD)
            
            coinValues.append(value)
        }
        
        totalPortfolioValueAsDollar(coinValues: coinValues)
    }
}

