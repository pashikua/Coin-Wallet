//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import SwiftHTTP
import SwiftyJSON
import Disk

class AddCoinViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var coinsPickerView: UIPickerView!
    
    @IBOutlet weak var holdingTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var coinData: [Coin] = [Coin]()
    
    var filteredCoinData: [Coin]!
    
    var holding: Float!
    
    var coin: Coin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.holdingTextField.delegate = self
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveCoinData()
    }
    
    @IBAction func addToWalletBtnPressed(_ sender: Any) {
        if holdingTextField.text != "" && holdingTextField.text != "0" && coin != nil {
            coin?.holding = holding
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
        coinData.removeAll()
        
        do {
            let retrievedCoinsData = try Disk.retrieve("coinsData.json", from: .caches, as: [Coin].self)
            
            for coin in retrievedCoinsData.sorted(by: {$0.rank! < $1.rank!}) {
                coinData.append(coin)
            }
            
            filteredCoinData = coinData
        } catch {
            print("Couldnt retrieve coin")
        }
    }
}

extension AddCoinViewController: UISearchBarDelegate {
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCoinData = searchText.isEmpty ? coinData : coinData.filter({ (coin) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return coin.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension AddCoinViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = filteredCoinData[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoinData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coin = filteredCoinData[indexPath.row]
        
        holdingTextField.becomeFirstResponder()
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
