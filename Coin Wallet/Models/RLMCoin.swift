//  Created by Özgür Celebi on 02.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation
import RealmSwift

final class RLMCoin: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var rank: Int = 0
    @objc dynamic var priceUSD: Float = 0.00
    @objc dynamic var priceBTC: Float = 0.00
    @objc dynamic var twentyFourHourVolumeUSD: Float = 0.00
    @objc dynamic var marketCapUSD: Float = 0.00
    @objc dynamic var availableSupply: Float = 0.00
    @objc dynamic var totalSupply: Float = 0.00
    @objc dynamic var percentChangeLastOneHour: Float = 0.00
    @objc dynamic var percentChangeLastTwentyFourHours: Float = 0.00
    @objc dynamic var percentChangeLastSevenDays: Float = 0.00
    @objc dynamic var lastUpdated: String = ""
    @objc dynamic var priceLocalCurrency: Float = 0.00
    @objc dynamic var twentyFourHourVolumeLocalCurrency: Float = 0.00
    @objc dynamic var marketCapLocalCurrency: Float = 0.00
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
