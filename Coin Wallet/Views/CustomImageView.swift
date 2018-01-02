//  Created by Özgür Celebi on 29.12.2017.
//  Copyright © 2017 Özgür Celebi. All rights reserved.

import UIKit

@IBDesignable
class CustomImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setup()
    }
    
    func setup() {
        layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
    }
}
