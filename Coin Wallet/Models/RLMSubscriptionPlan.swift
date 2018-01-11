//  Created by Özgür Celebi on 11.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation
import RealmSwift

final class RLMSubscriptionPlan: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var localizedDescription: String = ""
    @objc dynamic var localizedPrice: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

