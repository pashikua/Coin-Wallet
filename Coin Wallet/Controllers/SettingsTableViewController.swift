//  Created by Özgür Celebi on 28.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import SafariServices
import LocalAuthentication
import StoreKit

class SettingsTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var versionLabel: UILabel!
    
    let securityItems = ["Enable Passcode"]
    let aboutItems = ["Support Developer", "View Source Code", "Rate and give Feedback"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.versionLabel.text = "Version: " + getAppVersion()
    }
    
    @IBAction func passcodeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            print("true")
            authenticateUsingTouchID()
        } else {
            print("false")
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
                    DispatchQueue.main.async {
                        print("main queue accepted")
                    }
                } else {
                    DispatchQueue.main.async {
                        // Authentication failed. Show alert indicating what error occurred.
                        self.displayErrorMessage(error: error as! LAError )
                    }
                }
            })
        } else {
            print("Error")
            //Touch ID is not available on Device, use password.
            self.showAlertWith(title: "Error", message: (authErrorPointer?.localizedDescription)!)
        }
    }
    
    func displayErrorMessage(error:LAError) {
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
            message = "Passcode is not set on the device."
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        default:
            message = error.localizedDescription
        }
        
        self.showAlertWith(title: "Authentication Failed", message: message)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return [securityItems, aboutItems].count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        
        switch section {
        case 0:
            rows = securityItems.count
        case 1:
            rows = aboutItems.count
        default:
            break
        }
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                // Support Developer
                self.performSegue(withIdentifier: "SupportDeveloperSegue", sender: self)
            } else if indexPath.row == 1 {
                // Source Code
                presentOpenSourceProject()
            } else if indexPath.row == 2 {
                // Rate App
                SKStoreReviewController.requestReview()
            }
        default:
            break
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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
