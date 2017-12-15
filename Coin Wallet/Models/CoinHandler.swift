//
//  CoinHandler.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftHTTP
import Disk

class CoinHandler {
    static func getCoinsData(completion: @escaping (_ result: [Coin]) -> Void) {
        var coinsDataArray:[Coin] = [Coin]()
        
        HTTP.GET("https://api.coinmarketcap.com/v1/ticker") { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            
            do {
                let json = try JSON(data: response.data)
                
                for item in json {
                    let id = item.1["id"].string
                    let name = item.1["name"].string
                    let symbol = item.1["symbol"].string
                    let rank = item.1["rank"].intValue
                    let price_usd = item.1["price_usd"].floatValue
                    let last_updated = item.1["last_updated"].string
                    
                    coinsDataArray.append(Coin(id: id!, name: name!, symbol: symbol!, rank: rank, price_usd: price_usd, last_updated: last_updated!))
                }
                
                completion(coinsDataArray)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func updateCoinsDataOnDisk(coins: [Coin]) {
        do {
            if Disk.exists("coins.json", in: .caches) {
                print("coins exits in cache")
                try Disk.remove("coins.json", from: .caches)
            }
            
            for coin in coins {
                try Disk.append(coin, to: "coins.json", in: .caches)
            }
        } catch {
            print("Coudlnt save to disk")
        }
    }
}
