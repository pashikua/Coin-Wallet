//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit
import Kingfisher
import SwipeCellKit
import RealmSwift

class CoinTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var holdingValueLabel: UILabel!
    @IBOutlet weak var holdingCoinLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    
    func configCoinCell(with coin: RLMPortfolio, result: RLMCoin) {
        // Parse image from url
        let url = URL(string: "http://files.coinmarketcap.com.s3-website-us-east-1.amazonaws.com/static/img/coins/200x200/" + coin.id + ".png")!
        let placeHolderImage = UIImage(named: "coinIconPlaceHolder")
        self.coinImageView?.kf.setImage(with: url, placeholder: placeHolderImage)
        
//        if let img = UIImage(named: coin.id) {
//           self.coinImageView.image = img
//        }
        
        self.symbolLabel?.text = coin.symbol
        
        let value = coin.priceUSD * coin.holding
        self.holdingValueLabel?.text = value.changeToDollarCurrencyString()
        self.holdingCoinLabel?.text = coin.holding.description
        self.priceLabel?.text = coin.priceUSD.changeToDollarCurrencyString()
        
        if result.percentChangeLastTwentyFourHours > 0 {
            self.percentageChangeLabel.text = "+" + String(result.percentChangeLastTwentyFourHours) + "%"
        } else {
            self.percentageChangeLabel.text = String(result.percentChangeLastTwentyFourHours) + "%"
        }
        
    }
}
