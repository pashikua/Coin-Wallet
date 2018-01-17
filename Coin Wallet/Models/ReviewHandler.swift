//  Created by Özgür Celebi on 16.01.2018.
//  Copyright © 2018 Özgür Celebi. All rights reserved.

import Foundation
import StoreKit

class ReviewHandler {
    static func countLaunchesBeforeRequestingReview() {
        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        print("Launcounter: ", UserDefaults.standard.integer(forKey: "launchCount"))
        
        if launchCount == 3 {
            SKStoreReviewController.requestReview()
        }
        
        UserDefaults.standard.set(launchCount + 1, forKey: "launchCount")
    }
}
