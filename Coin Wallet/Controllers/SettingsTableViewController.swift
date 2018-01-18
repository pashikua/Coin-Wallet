//  Created by Özgür Celebi on 28.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import SafariServices
import LocalAuthentication
import StoreKit

class SettingsTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    let securityItems = ["Enable Biometric Lock"]
    let aboutItems = ["View Source Code", "Rate and give Feedback", "Share with Friends"]
    let linkItems = ["Buy and Sell on Coinbase", "Buy and Sell on Binance"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.versionLabel.text = "Version: " + getAppVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSwitch()
    }
    
    @IBAction func touchIDSwitch(_ sender: UISwitch) {
        if sender.isOn {
            print("true")
            authenticateUsingTouchID()
        } else {
            print("false")
            UserDefaults.standard.set(false, forKey: "isTouchIDEnabled")
        }
    }
    
    func setSwitch() {
        // Set switch accordingly
        if UserDefaults.standard.bool(forKey: "isTouchIDEnabled") {
            DispatchQueue.main.async {
                self.touchIDSwitch.isOn = true
            }
        } else {
            DispatchQueue.main.async {
                self.touchIDSwitch.isOn = false
            }
        }
    }
    
    func getAppVersion() -> String {
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }
    
    func authenticateUsingTouchID() {
        let authContext = LAContext()
        let authReason = "You are turning on Touch ID to lock your Coin Portfolio"
        var authErrorPointer: NSError?
        
        if authContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authErrorPointer) {
            authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason, reply: { (success, error) in
                if success {
                    print("authenticate successfully")
                    UserDefaults.standard.set(true, forKey: "isTouchIDEnabled")
                } else {
                    DispatchQueue.main.async {
                        // Authentication failed. Show alert indicating what error occurred.
                        print("Display Error Message")
                        self.touchIDSwitch.isOn = false
                        self.displayErrorMessage(error: error as! LAError )
                        let err = error as! LAError
                    }
                }
            })
        } else {
            print("Error")
            DispatchQueue.main.async {
                self.touchIDSwitch.isOn = false
            }
            // Touch ID is not available on Device, use password.
            if authErrorPointer?.code == -7 {
                self.showAlertWith(title: "Error", message: "Biometric Authentication is not enabled on this Device. Enable it and try again")
            } else {
                self.showAlertWith(title: "Error", message: (authErrorPointer?.localizedDescription)!)
            }
        }
    }
    
    func displayErrorMessage(error: LAError) {
        print(error.code)
        print(error._nsError)
        
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
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device"
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        case LAError.biometryNotEnrolled:
            message = "Enable FaceID or TouchID to use the feature"
        default:
            message = error.localizedDescription
            print(error.code)
            print(error._nsError)
        }
        
        self.showAlertWith(title: "Authentication Failed", message: message)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return [securityItems, aboutItems, linkItems].count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        
        switch section {
        case 0:
            rows = securityItems.count
        case 1:
            rows = aboutItems.count
        case 2:
            rows = linkItems.count
        default:
            break
        }
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        switch indexPath.section {
        case 1:
//            if indexPath.row == 0 {
//                // Support Developer
////                self.performSegue(withIdentifier: "SupportDeveloperSegue", sender: self)
//            } else
            
            if indexPath.row == 0 {
                // Source Code
                presentOpenSourceProject()
            } else if indexPath.row == 1 {
                // Rate App
                SKStoreReviewController.requestReview()
            } else if indexPath.row == 2 {
                // Share App
                shareApp()
            }
        case 2:
            if indexPath.row == 0 {
                // Open link to Coinbase
                self.openLinkWithSafari(string: "https://www.coinbase.com/join/5a2ac0a68c4feb0308f73ba4")
            }
            if indexPath.row == 1 {
                // Open link to Binance
                self.openLinkWithSafari(string: "https://www.binance.com/?ref=12691359")
            }
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "SupportDeveloperSegue" {
            
        }
    }
    */
    
    private func shareApp() {
        // Placeholder message
        let shareText = "Hey, I am using this Coin Portfolio tracking App :)  "
        
        // iTunes link to the app store
        let shareAppURL = URL(string: "https://itunes.apple.com/app/coin-portfolio-tracking/id1326852500")!
        
        let vc = UIActivityViewController(activityItems: [shareText, shareAppURL], applicationActivities: [])
        vc.excludedActivityTypes = [
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.airDrop,
            UIActivityType.openInIBooks
        ]
        self.present(vc, animated: true)
    }
 
    func openLinkWithSafari(string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    // MARK: - Safari
    
    func presentOpenSourceProject() {
        guard let url = URL(string: "https://github.com/oezguercelebi/Coin-Wallet") else {
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


extension UIViewController {
    func showAlertWith(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
