//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import Fabric
import Crashlytics
import SwiftyStoreKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
//        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
//        Crashlytics.sharedInstance().crash()
        
        completeIAPTransactions()
        
        checkForTouchID()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // Mark: - TouchID
    
    func checkForTouchID() {
        if UserDefaults.standard.bool(forKey: "isTouchIDEnabled") {
            // Check for fingerprint
            print("check for fingerprint")
            // Send user to Empty View Controlller while checking for TouchID
            
            let storyboard = UIStoryboard.init(name: "Empty", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "EmptyVC") as! EmptyViewController
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
            
            let authContext = LAContext()
            let authReason = "You are turning on Biometric Securiy to lock your Coin Portfolio"
            
            authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason, reply: { (success, error) in
                
                if success {
                    // Verified Successfully
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! NavigationViewController
                        
                        self.window?.rootViewController = viewController
                        self.window?.makeKeyAndVisible()
                    }
                } else {
                    print("Authentification Failed")
                    // Failed to Verification
                    DispatchQueue.main.async {
                        viewController.infoLabel.text = self.displayErrorMessage(error: error as! LAError)
                        viewController.infoLabel.isHidden = false
                    }
                }
            })
        } else {
            print("Touch ID is not enabled")
            // Let user through since TouchID is not enabled
            DispatchQueue.main.async {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! NavigationViewController
                
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func displayErrorMessage(error: LAError) -> String {
        var message = ""
        switch error.code {
        case LAError.authenticationFailed:
            message = "Authentication was not successful because the user failed to provide valid credentials."
            break
        case LAError.userCancel:
            message = "Authentication was canceled by the user"
            break
        case LAError.userFallback:
            message = "Authentication was canceled because the user tapped the fallback button"
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        case LAError.biometryNotEnrolled:
            message = "Biometry Authentication is enabled for Coin Portfolio. Until you haven't enabled FaceID or TouchID you can't get back in."
            break
        default:
            message = error.localizedDescription
        }
        
        return message
    }
    
    // Mark: - SwiftyStoreKit

    func completeIAPTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
}

