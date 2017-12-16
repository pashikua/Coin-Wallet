//
//  CoinDataService.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit
import SwipeCellKit
import SCLAlertView

class CoinDataService: NSObject, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    var coinManager: CoinManager?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (coinManager?.coinsCount)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinTableViewCell
        
        guard let coinManager = coinManager else { fatalError() }
        
        let coin = coinManager.coinAtIndex(index: indexPath.row)
        
        cell.delegate = self
        cell.configCoinCell(withCoin: coin)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: show detailed view
        print("Did select row at:", indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // handle action by updating model with edit
            
            // Customize
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 19)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            let valueInString = String(describing: self.coinManager!.coinAtIndex(index: indexPath.row).holding!)
            let valueTextField = alert.addTextField(valueInString)
            valueTextField.keyboardType = .decimalPad
            alert.addButton("Done") {
                // Todo: check if value is correct and save to current index coin
                // plus update the coin disk values, then reload current tableview data
                print("Finished updating value: ", valueTextField.text!)
            }
            
            alert.showCustom("Edit", subTitle: "Update your holding value", color: .primaryColor, icon: UIImage(named: "editFilled")!)
            
            
            tableView.reloadData()
        }
        // customize the action appearance
        editAction.image = UIImage(named: "editRoundFilled")
        editAction.backgroundColor = .white
        editAction.textColor = .lightDarkColor
        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.coinManager?.removeCoinFromLibrary(index: indexPath.row)
            
            tableView.reloadData()
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "deleteRoundFilled")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = .lightDarkColor
        
        return [editAction, deleteAction]
    }
}
