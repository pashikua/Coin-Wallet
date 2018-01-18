//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import SwipeCellKit
import SCLAlertView

class CoinDataService: NSObject, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate, UITextFieldDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmManager.sharedInstance.coinsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinTableViewCell
        
        
        
        let coin = RealmManager.sharedInstance.coinAtIndex(index: indexPath.row)
        let coinResult = RealmManager.sharedInstance.getResultsByCoinID(index: indexPath.row)
        
        cell.delegate = self
        cell.configCoinCell(with: coin, result: coinResult)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: show detailed view
        print("Did select row at:", indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // Customize SCLAlertView appearance
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 19)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            let valueInString = String(describing: RealmManager.sharedInstance.coinAtIndex(index: indexPath.row).holding)
            let valueTextField = alert.addTextField(valueInString)
            valueTextField.delegate = self
            valueTextField.keyboardType = .decimalPad
            valueTextField.becomeFirstResponder()
            alert.addButton("Done") {
                
                // Check for correct string value
                if valueTextField.text != "" && valueTextField.text != "0" && valueTextField.text != "," && valueTextField.text != "." {
                    let holding = Float(valueTextField.text!.replacingOccurrences(of: ",", with: "."))
                    
                    // TODO: Shitty solution needs to be fixed
                    let oldCoin = RealmManager.sharedInstance.coinAtIndex(index: indexPath.row)
                    let coin = RLMPortfolio()
                    coin.id = oldCoin.id
                    coin.holding = holding!
                    coin.priceUSD = oldCoin.priceUSD
                    coin.symbol = oldCoin.symbol
                    coin.rank = oldCoin.rank
                    
                    DispatchQueue.main.async {
                        RealmManager.sharedInstance.updatePortfolioObject(coin: coin)
                        tableView.reloadData()
                    }
                }
            }
            
            alert.showCustom("Edit", subTitle: "Enter new value", color: .primaryColor, icon: UIImage(named: "editFilled")!)
        }
        // Customize appearance
        editAction.image = UIImage(named: "editRoundFilled")
        editAction.backgroundColor = .white
        editAction.textColor = .midDarkColor
        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            RealmManager.sharedInstance.deletePortfolioObject(index: indexPath.row)
            
            tableView.reloadData()
        }
        // Customize appearance
        deleteAction.image = UIImage(named: "deleteRoundFilled")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = .midDarkColor
        
        return [editAction, deleteAction]
    }
}

extension CoinDataService {
    // Dont allow more then one comma or point
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countDots = (textField.text?.components(separatedBy: ".").count)! - 1
        let countCommas = (textField.text?.components(separatedBy: ",").count)! - 1
        
        if countDots > 0 && string == "." || countCommas > 0 && string == "," {
            return false
        }
        
        return true
    }
}
