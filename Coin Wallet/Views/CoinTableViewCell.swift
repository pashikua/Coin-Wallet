//
//  CoinTableViewCell.swift
//  Coin Wallet
//
//  Created by Özgür Celebi on 11.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit

class CoinTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var holdingValueLabel: UILabel!
    @IBOutlet weak var holdingCoinLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configCoinCell(withCoin: Coin) {
        let url = URL(string: "http://files.coinmarketcap.com.s3-website-us-east-1.amazonaws.com/static/img/coins/200x200/" + withCoin.id + ".png")!
        self.coinImageView?.kf.setImage(with: url)
        
        self.symbolLabel?.text = withCoin.symbol
        
        if let priceUSD = withCoin.price_usd, let holding = withCoin.holding {
            let value = priceUSD * holding
            self.holdingValueLabel?.text = value.changeToDollarCurrencyString()
            self.holdingCoinLabel?.text = withCoin.holding?.description
            self.priceLabel?.text = withCoin.price_usd!.changeToDollarCurrencyString()
        }
    }
}
