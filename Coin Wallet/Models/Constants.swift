//  Created by Özgür Celebi on 15.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import Foundation
import RealmSwift

//  Constants
struct Constants {
    
    public static func AppGroupConfiguration() -> Realm.Configuration {
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oezguercelebi.Coin-Wallet")!
        let realmPath = directory.appendingPathComponent("db.realm")
        var config = Realm.Configuration()
        config.fileURL = realmPath
        
        return config
    }
}
