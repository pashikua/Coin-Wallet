//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import Foundation
import SwiftyJSON
import SwiftHTTP
import RealmSwift

// TODO: Impelement later local currency that was choosen by user
class CoinHandler {
    typealias CompletionHandler = (_ success: Bool) -> Void
    
    static func fetchCoinsData(completion: @escaping CompletionHandler) {
        HTTP.GET("https://api.coinmarketcap.com/v1/ticker/?limit=200") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            do {
                let json = try JSON(data: response.data)
                
                // Mark: - REALM
                
                let realm = try! Realm()
                
                try realm.write {
                    for item in json {
                        let allCoins = RLMCoin()
                        allCoins.id = item.1["id"].stringValue
                        allCoins.name = item.1["name"].stringValue
                        allCoins.symbol = item.1["symbol"].stringValue
                        allCoins.rank = item.1["rank"].intValue
                        allCoins.priceUSD = item.1["price_usd"].floatValue
                        allCoins.priceBTC = item.1["price_btc"].floatValue
                        allCoins.twentyFourHourVolumeUSD = item.1["24h_volume_usd"].floatValue
                        allCoins.marketCapUSD = item.1["market_cap_usd"].floatValue
                        allCoins.availableSupply = item.1["available_supply"].floatValue
                        allCoins.totalSupply = item.1["total_supply"].floatValue
                        allCoins.percentChangeLastOneHour = item.1["percent_change_1h"].floatValue
                        allCoins.percentChangeLastTwentyFourHours = item.1["percent_change_24h"].floatValue
                        allCoins.percentChangeLastSevenDays = item.1["percent_change_7d"].floatValue
                        allCoins.lastUpdated = item.1["last_updated"].stringValue
                        
                        realm.add(allCoins, update: true)
                        // Upcomming feature
//                        allCoins.priceLocalCurrency = item.1[""].floatValue
//                        allCoins.twentyFourHourVolumeLocalCurrency = item.1["24h_volume_eur"].floatValue
//                        allCoins.marketCapLocalCurrency = item.1[""].floatValue
                        
                        
                    }
                }
                DispatchQueue.main.async {
                    RealmManager.sharedInstance.refreshPortfolioData()
                }
                
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
