//  Created by Özgür Celebi on 02.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import UIKit
import RealmSwift
import SwiftyStoreKit

protocol RealmManagerDelegate: class {
    func updatePortfolioValue(_ coinsPortfolio: [RLMPortfolio])
}
class RealmManager {
    
    weak var delegate: RealmManagerDelegate?
    
    private var realm: Realm
    static let sharedInstance = RealmManager()
    
    private init() {
        realm = try! Realm(configuration: Constants.AppGroupConfiguration())
    }
    
    var coinsCount: Int { return portfolioCoins.count }
    
    private var portfolioCoins = [RLMPortfolio]()
    
    func coinAtIndex(index: Int) -> RLMPortfolio {
        return portfolioCoins[index]
    }
    
    func getResultsByCoinID(index: Int) -> RLMCoin {
        let coin = realm.objects(RLMCoin.self).filter("id CONTAINS '\(portfolioCoins[index].id)'").first
        
        return coin!
    }
    
    func getCoinsDataFromRealm() -> Results<RLMCoin> {
        let results = realm.objects(RLMCoin.self)
        return results
    }
    
    func getPortfolioDataFromRealm() -> Results<RLMPortfolio> {
        let results = realm.objects(RLMPortfolio.self)
        return results
    }
    
    func getSubscriptionPlanDataFromRealm() -> Results<RLMSubscriptionPlan> {
        let results = realm.objects(RLMSubscriptionPlan.self)
        return results
    }
    
    func getPortfolioCoinsArray() -> [RLMPortfolio] {
        return portfolioCoins
    }
    
    
    func deleteAllFromRealm()  {
        try! realm.write {
            realm.deleteAll()
            print("delete all database")
        }
    }
    
    func updatePortfolioCoinArray() {
        portfolioCoins.removeAll()
        
        if let sortByKeyPath = UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.string(forKey: "sortByKeyPath") {
            if let isAscending = UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.bool(forKey: "sortIsAscending") {
                for coin in realm.objects(RLMPortfolio.self).sorted(byKeyPath: sortByKeyPath, ascending: isAscending).toArray(ofType: RLMPortfolio.self) {
                    portfolioCoins.append(coin)
                }
            }
        } else {
            for coin in realm.objects(RLMPortfolio.self).sorted(byKeyPath: "rank", ascending: true).toArray(ofType: RLMPortfolio.self) {
                portfolioCoins.append(coin)
            }
        }
    }
    
    func addRLMObject(object: Object, update: Bool) {
        try! realm.write {
            realm.add(object, update: update)
            print("add realm object")
        }
    }
    
    func updatePortfolioObject(coin: RLMPortfolio) {
        // Change holding value before updating
        print("should update from database and array index")
        try! realm.write {
            realm.add(coin, update: true)

            print("updated object from database")
        }
        
        updatePortfolioCoinArray()
        delegate?.updatePortfolioValue(portfolioCoins)
    }
    
    func deletePortfolioObject(index: Int) {
        print("should delete from database and array index")
        try! realm.write {
            realm.delete(portfolioCoins[index])
            
            print("deleted object from database")
        }
        updatePortfolioCoinArray()
        delegate?.updatePortfolioValue(portfolioCoins)
    }
    
    func sortPorfolioCoins(ascending: Bool, keyPath: String) {
        if portfolioCoins.count != 0 {
            portfolioCoins.removeAll()
            
            let results = realm.objects(RLMPortfolio.self)
            let sortedCoins = results.sorted(byKeyPath: keyPath, ascending: ascending).toArray(ofType: RLMPortfolio.self)
            
            portfolioCoins = sortedCoins
        }
    }
    
    func refreshPortfolioData() {
        let portfolio = realm.objects(RLMPortfolio.self).toArray(ofType: RLMPortfolio.self)
        let coins = realm.objects(RLMCoin.self).toArray(ofType: RLMCoin.self)
        
        try! realm.write {
            // Update current portfolio values
            for portfolioCoin in portfolio {
                for coin in coins {
                    if portfolioCoin.id == coin.id {
                        let updatedCoin = RLMPortfolio()
                        updatedCoin.id = coin.id
                        updatedCoin.priceUSD = coin.priceUSD
                        updatedCoin.symbol = coin.symbol
                        updatedCoin.rank = coin.rank
                        updatedCoin.holding = portfolioCoin.holding
                        
                        realm.add(updatedCoin, update: true)
                    }

                }
            }
            print("updated object from database")
        }
    }
    
    // TODO: Extract code logic from here
    func fetchSubPlans() {
        let appBundleId = "com.oezguercelebi.coinwallet.sub"
        let purchasePlusSupporter = "plussupporter"
        let purchasePremiumSupporter = "premiumsupporter"
        let purchaseMaxSupporter = "maxsupporter"
        
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchasePlusSupporter]) { result in
            
            if let product = result.retrievedProducts.first {
                if let priceString = product.localizedPrice {
                    let plusSupporterPlan = RLMSubscriptionPlan()
                    plusSupporterPlan.id = purchasePlusSupporter
                    plusSupporterPlan.localizedPrice = priceString
                    plusSupporterPlan.localizedDescription = product.localizedDescription
                    
                    try! self.realm.write {
                        self.realm.add(plusSupporterPlan, update: true)
                    }
                }
            }
        }
        
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchasePremiumSupporter]) { result in
            
            if let product = result.retrievedProducts.first {
                if let priceString = product.localizedPrice {
                    let premiumSupporterPlan = RLMSubscriptionPlan()
                    premiumSupporterPlan.id = purchasePremiumSupporter
                    premiumSupporterPlan.localizedPrice = priceString
                    premiumSupporterPlan.localizedDescription = product.localizedDescription
                    
                    try! self.realm.write {
                        self.realm.add(premiumSupporterPlan, update: true)
                    }
                }
            }
        }
        
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchaseMaxSupporter]) { result in
            
            if let product = result.retrievedProducts.first {
                if let priceString = product.localizedPrice {
                    let maxSupporterPlan = RLMSubscriptionPlan()
                    maxSupporterPlan.id = purchaseMaxSupporter
                    maxSupporterPlan.localizedPrice = priceString
                    maxSupporterPlan.localizedDescription = product.localizedDescription
                    
                    try! self.realm.write {
                        self.realm.add(maxSupporterPlan, update: true)
                    }
                }
            }
        }
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}
