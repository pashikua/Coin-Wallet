//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Özgür Celebi on 27.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var totalPortfolioValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextLabel.text = "Total Portfolio Value"
        
        if let total = UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.float(forKey: "totalPortfolioValue") {
            print(total)
            totalPortfolioValueLabel.text = total.changeToDollarCurrencyString()
        } else {
            totalPortfolioValueLabel.text = "$0.00"
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let total = UserDefaults.init(suiteName: "group.com.oezguercelebi.Coin-Wallet")?.float(forKey: "totalPortfolioValue") {
            print(total)
            totalPortfolioValueLabel.text = total.changeToDollarCurrencyString()
            completionHandler(NCUpdateResult.newData)
        }
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
