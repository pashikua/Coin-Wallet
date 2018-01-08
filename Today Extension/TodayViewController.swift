//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Özgür Celebi on 27.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift
import SwiftHTTP
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var totalPortfolioValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoTextLabel.text = "TOTAL PORTFOLIO VALUE"
        totalPortfolioValueLabel.text = UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.float(forKey: "totalPortfolioValue").changeToDollarCurrencyString() ?? "$0.00"
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        _ = CoinHandler.fetchCoinsData(completion: { (success) in
            if success {
                DispatchQueue.main.async {
                    RealmManager.sharedInstance.updatePortfolioCoinArray()
                    
                    var coinValues: [Float] = []
                    let coinsArray = RealmManager.sharedInstance.getPortfolioCoinsArray()
                    
                    for coin in coinsArray {
                        // Multiply coin holding with current price of coin
                        let value = Float(coin.holding) * Float(coin.priceUSD)
                        
                        coinValues.append(value)
                    }
                    let total = coinValues.reduce(0, +)
                    
                    self.totalPortfolioValueLabel.text = total.changeToDollarCurrencyString()
                    
                    // Save to default groups
                    UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.setValue(total, forKey: "totalPortfolioValue")
                    
                    completionHandler(NCUpdateResult.newData)
                }
            }
        })
    }
}

extension Float {
    func changeToDollarCurrencyString() -> String {
        let number = NSNumber(value: self)
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "en_US")
        let priceString = currencyFormatter.string(from: number)
        return priceString!
    }
}
