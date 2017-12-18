//  Created by Özgür Celebi on 15.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import Foundation

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
