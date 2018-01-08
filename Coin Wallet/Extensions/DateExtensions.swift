//  Created by Özgür Celebi on 08.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation

extension Date {
    var currentUTCTimeZoneDateAsString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: self)
    }
}
