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
        RealmManager.sharedInstance.delegate = self
        
        // Configure Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)
        self.view.layoutIfNeeded()

        observeNotification()
        addBlurEffectView()
        
        refreshCoinData(refreshControl)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        updateTableViewAndTotalPortfolioLabel()
    }
    
    @objc func refreshCoinData(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        print("refreshCoinDataTriggered")
        if RealmManager.sharedInstance.coinsCount != 0 {
            _ = CoinHandler.fetchCoinsData(completion: { (success) in

                if success {
                    DispatchQueue.main.async {
                        RealmManager.sharedInstance.updatePortfolioCoinArray()
                        self.coinTableView.reloadData()
                        self.updateTotalPortfolioLabel(coinsArray: RealmManager.sharedInstance.getPortfolioCoinsArray())
                        sender.endRefreshing()
                    }
                }
            })
        } else {
            print("coinscount: ", RealmManager.sharedInstance.coinsCount)
            sender.endRefreshing()
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
            self.refreshControl.endRefreshing()
        }
    }
    
    func totalPortfolioValueAsDollar(coinValues: [Float]) {
        DispatchQueue.main.async {
            let total = coinValues.reduce(0, +)
            UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.setValue(total, forKey: "totalPortfolioValue")
            self.totalPortfolioValueLabel.text = total.changeToDollarCurrencyString()
        }
    }
    
    func updateTableViewAndTotalPortfolioLabel() {
        RealmManager.sharedInstance.updatePortfolioCoinArray()
        coinTableView.reloadData()
        self.updateTotalPortfolioLabel(coinsArray: RealmManager.sharedInstance.getPortfolioCoinsArray())
    }
    
    // First version used Disk and I switched to Realm
    func switchToRealmDatabase() {
        do {
            DispatchQueue.main.async {
                HUD.show(.label("Upgrading Database..."))
            }
            
            let retrievedCoins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)

            for coin in retrievedCoins {
                let portfolio = RLMPortfolio()
                portfolio.id = coin.id
                portfolio.holding = coin.holding!
                RealmManager.sharedInstance.addPortfolioObject(object: portfolio)
            }
            
            DispatchQueue.main.async {
                HUD.hide(afterDelay: 1.7)
            }
            // After updating its time to clean old data on disk
            clearOldDiskDataFromCaches()
        } catch {
            print("Couldnt retrieve coin")
            endRefresh()
        }
    }
    
    func clearOldDiskDataFromCaches() {
        do {
            if Disk.exists("coins.json", in: .caches) {
                print("coins exits in cache")
                try Disk.remove("coins.json", from: .caches)
            }
            
            if Disk.exists("coinsData.json", in: .caches) {
                print("coins data exits in cache")
                try Disk.remove("coinsData.json", from: .caches)
            }
        } catch {
            print("Couldnt clear disk")
        }
    }
}

extension MainViewController {
    // Mark: - BlurEffect related

    // Blur main view while app is in background
    func addBlurEffectView() {
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
    
    func observeNotification() {
        let ncResignActive = NotificationCenter.default
        ncResignActive.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let ncBecomeActive = NotificationCenter.default
        ncBecomeActive.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
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

