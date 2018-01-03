//  Created by Özgür Celebi on 02.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import UIKit
import RealmSwift

protocol RealmManagerDelegate: class {
    func updatePortfolioValue(_ coinsPortfolio: [RLMPortfolio])
}
class RealmManager {
    
    weak var delegate: RealmManagerDelegate?
    
    private var realm: Realm
    static let sharedInstance = RealmManager()
    
    private init() {
        realm = try! Realm()
    }
    
    var coinsCount: Int { return portfolioCoins.count }
    
    private var portfolioCoins = [RLMPortfolio]()
    
    func coinAtIndex(index: Int) -> RLMPortfolio {
        return portfolioCoins[index]
    }
    
    func getCoinsDataFromRealm() -> Results<RLMCoin> {
        let results = realm.objects(RLMCoin.self)
        return results
    }
    
    func getPortfolioDataFromRealm() -> Results<RLMPortfolio> {
        let results = realm.objects(RLMPortfolio.self)
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
        
        for coin in realm.objects(RLMPortfolio.self).sorted(byKeyPath: "rank").toArray(ofType: RLMPortfolio.self) {
            
            portfolioCoins.append(coin)
        }
    }
    
    func addPortfolioObject(object: RLMPortfolio)   {
        try! realm.write {
            realm.add(object, update: true)
            print("add new object to portfolio")
        }
    }
    
    func updatePortfolioObject(coin: RLMPortfolio) {
        // TODO: Change holding value before updating
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
    
    func refreshPortfolioData() {
        print("refresh portfolio data")

        // TODO: Update current portfolio values
        for portfolioCoin in realm.objects(RLMPortfolio.self).toArray(ofType: RLMPortfolio.self) {
            for coin in realm.objects(RLMCoin.self).toArray(ofType: RLMCoin.self) {
                if portfolioCoin.id == coin.id {
                    let updatedCoin = RLMPortfolio()
                    updatedCoin.id = coin.id
                    updatedCoin.priceUSD = coin.priceUSD
                    updatedCoin.symbol = coin.symbol
                    updatedCoin.rank = coin.rank
                    updatedCoin.holding = portfolioCoin.holding

//                    realm.add(updatedCoin, update: true)
                    try! realm.write {
                        realm.add(updatedCoin, update: true)
                        
                        print("updated object from database")
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