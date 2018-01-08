//  Created by Özgür Celebi on 08.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation
import RealmSwift

final class RLMDailyTotalValue: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var totalValue: Float = 0.00
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
