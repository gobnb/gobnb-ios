//
//  ShoppingCartView.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 02/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

@IBDesignable class ShoppingCartView: UIView {

    var view: UIView!
    
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var totalQty: UILabel!
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //view.autoresizingMask = UIView.AutoresizingMask.FlexibleWidth | UIView.AutoresizingMask.flexibleHeight(view)
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "ShoppingCartView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBInspectable var mytitleLabelText: String? {
        get {
            return totalPrice.text
        }
        set(mytitleLabelText) {
            totalPrice.text = mytitleLabelText
        }
    }
    
    @IBAction func viewCartPressed(_ sender: Any) {
        print("view pressed")
    }
    
}
