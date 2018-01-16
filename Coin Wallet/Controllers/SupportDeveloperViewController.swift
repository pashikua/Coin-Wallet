//  Created by Özgür Celebi on 28.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import StoreKit
import SwiftyStoreKit
import PKHUD
import SafariServices

enum RegisteredPurchase: String {
    case plusSupporter
    case premiumSupporter
    case maxSupporter
}

class SupportDeveloperViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var subcriptionsInfoLabel: UILabel!
    @IBOutlet weak var subcriptionTermsLabel: UILabel!
    
    @IBOutlet weak var plusSupporterBtn: CustomButton!
    @IBOutlet weak var premiumSupporterBtn: CustomButton!
    @IBOutlet weak var maxSupporterBtn: CustomButton!
    let appBundleId = "com.oezguercelebi.coinwallet.sub"
    
    let purchasePlusSupporter = RegisteredPurchase.plusSupporter
    let purchasePremiumSupporter = RegisteredPurchase.premiumSupporter
    let purchaseMaxSupporter = RegisteredPurchase.maxSupporter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPriceButtonTitles()
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(SupportDeveloperViewController.infoLabelTapped))
        subcriptionTermsLabel.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Support Developer"
        self.subcriptionsInfoLabel.text = "Coin Portolio subscription plans will be billed annually"
    }
    
    
    @IBAction func plusBtnPressed(_ sender: UIButton) {
        print("plus supporter")
        purchase(purchasePlusSupporter)
    }
    
    @IBAction func premiumBtnPressed(_ sender: UIButton) {
        print("premium supporter")
        purchase(purchasePremiumSupporter)
    }
    
    @IBAction func maxBtnPressed(_ sender: UIButton) {
        print("max supporter")
        purchase(purchaseMaxSupporter)
    }
    
    @objc func infoLabelTapped(sender:UITapGestureRecognizer) {
        print("tap working")
        presentTermsAndPrivacyPolicy()
    }
    
    // Mark: - SwiftyStoreKit

    func setupPriceButtonTitles() {
        
        let objects = RealmManager.sharedInstance.getSubscriptionPlanDataFromRealm()
        for object in objects {
            if object.id == "plussupporter" {
                self.plusSupporterBtn.setTitle(("\(object.localizedPrice) / 1 year"), for: .normal)
            }
            if object.id == "premiumsupporter" {
                self.premiumSupporterBtn.setTitle(("\(object.localizedPrice) / 1 year"), for: .normal)
            }
            if object.id == "maxsupporter" {
                self.maxSupporterBtn.setTitle(("\(object.localizedPrice) / 1 year"), for: .normal)
            }
        }
    }
    
    func getInfo(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue.lowercased()]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.showAlert(self.alertForProductRetrievalInfo(result))
        }
    }
    
    func purchase(_ purchase: RegisteredPurchase) {
//        HUD.show(.label("Requesting Purchase..."))
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue.lowercased(), atomically: true) { result in
            HUD.hide()
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        var sharedSecret: String!
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            print(dict["sharedSecret"] as! String)
            sharedSecret = dict["sharedSecret"] as! String
        }
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    func verifyPurchase(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                
                let productId = self.appBundleId + "." + purchase.rawValue.lowercased()
                
                switch purchase {
                case .plusSupporter:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt,
                        validUntil: Date()
                    )
                    self.showAlert(self.alertForVerifySubscription(purchaseResult))
                case .premiumSupporter:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt,
                        validUntil: Date()
                    )
                    self.showAlert(self.alertForVerifySubscription(purchaseResult))
                case .maxSupporter:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt,
                        validUntil: Date()
                    )
                    self.showAlert(self.alertForVerifySubscription(purchaseResult))
                }
                
            case .error:
                self.showAlert(self.alertForVerifyReceipt(result))
            }
        }
    }
    
    // MARK: - Safari
    
    func presentTermsAndPrivacyPolicy() {
        guard let url = URL(string: "https://coinportfolio.co/#privacy") else {
            return //be safe
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - User facing alerts
extension SupportDeveloperViewController {
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}
