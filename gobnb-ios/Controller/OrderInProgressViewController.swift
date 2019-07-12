//
//  OrderInProgressViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 12/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import CountdownLabel

class OrderProgressViewController : UIViewController {
    
    @IBOutlet weak var countdown: CountdownLabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        countdown.setCountDownTime(minutes: 60*30)
        countdown.start()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
        let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
        shoppingCartView.totalPrice.text = "\(totalPriceInCart) BNB"
        shoppingCartView.totalQty.text = "\(totalItemsInCart)"
        shoppingCartView.viewCartButton.setTitle("Pay Now", for: .normal)
        shoppingCartView.viewCartButton.addTarget(self, action: Selector(("paymentButtonTapped:")), for: .touchUpInside)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

