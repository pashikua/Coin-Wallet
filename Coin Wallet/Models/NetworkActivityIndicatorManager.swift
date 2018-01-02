//
//  NetworkActivityIndicatorManager.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 29.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit

class NetworkActivityIndicatorManager: NSObject {
    
    private static var loadingCount = 0
    
    class func networkOperationStarted() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func networkOperationFinished() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
