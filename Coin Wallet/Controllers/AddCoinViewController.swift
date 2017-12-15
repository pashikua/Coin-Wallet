//
//  AddCoinViewController.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftyJSON
import Disk

class AddCoinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var coinsPickerView: UIPickerView!
    
    @IBOutlet weak var holdingTextField: UITextField!
    
    var pickerData: [Coin] = [Coin]()
    
    var holding: Float!
    
    var coin: Coin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect data
        self.coinsPickerView.dataSource = self
        self.coinsPickerView.delegate = self
        
        self.holdingTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveCoinData()
    }
    
    @IBAction func addToWalletBtnPressed(_ sender: Any) {
        print(coin)
        print(holding)
        
        coin.holding = holding
        print(coin)
        
        if holdingTextField.text != "" && holdingTextField.text != "0" {
            saveCoinToDisk()
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func textfieldEditingChanged(_ sender: Any) {
        holding = Float(holdingTextField.text!.replacingOccurrences(of: ",", with: "."))
    }
    
    func saveCoinToDisk() {
        do {
            try Disk.append(coin, to: "coins.json", in: .caches)
        } catch {
            print("Coudlnt save to disk")
        }
    }
    
    func retrieveCoinData() {
        pickerData.removeAll()
        
        do {
            let retrievedCoinsData = try Disk.retrieve("coinsData.json", from: .caches, as: [Coin].self)
            
            for coin in retrievedCoinsData.sorted(by: {$0.rank! < $1.rank!}) {
                pickerData.append(coin)
            }
            
            coin = pickerData[0]
        } catch {
            print("Couldnt retrieve coin")
        }
    }
}

extension AddCoinViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row].name
        let title = NSAttributedString(string: titleData!, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor(red:0.22, green:0.25, blue:0.29, alpha:1.0)])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerData[row].name)
        coin = pickerData[row]
    }
}

extension AddCoinViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countDots = (holdingTextField.text?.components(separatedBy: ".").count)! - 1
        let countCommas = (holdingTextField.text?.components(separatedBy: ",").count)! - 1
        
        if countDots > 0 && string == "." || countCommas > 0 && string == "," {
            return false
        }
        
        return true
    }
}
