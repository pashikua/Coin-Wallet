//  Created by Özgür Celebi on 02.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation
import RealmSwift

final class RLMPortfolio: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var holding: Float = 0.00
    @objc dynamic var symbol: String = ""
    @objc dynamic var priceUSD: Float = 0.00
    @objc dynamic var rank: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
