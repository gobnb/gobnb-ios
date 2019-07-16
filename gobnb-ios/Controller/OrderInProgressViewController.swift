//
//  OrderInProgressViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 12/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import CountdownLabel
import SVProgressHUD
import BinanceChain
import SwiftKeychainWrapper

class OrderProgressViewController : UIViewController {
    
    @IBOutlet weak var countdown: CountdownLabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    var totalPriceInCart : Double = 0.00
    var totalItemsInCart : Int = 0
    var addressToPay:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdown.setCountDownTime(minutes: 60*30)
        countdown.start()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
        totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
        shoppingCartView.totalPrice.text = "\(totalPriceInCart) BNB"
        shoppingCartView.totalQty.text = "\(totalItemsInCart)"
        shoppingCartView.viewCartButton.setTitle("Pay Now", for: .normal)
        shoppingCartView.viewCartButton.addTarget(self, action: Selector(("paymentButtonTapped:")), for: .touchUpInside)
        addressToPay = UserDefaults.standard.string(forKey: "peopleAddress") ?? ""
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func paymentButtonTapped(_ sender: UIButton){
        SVProgressHUD.show()
        let binance = BinanceChain(endpoint: .testnet)
        let walletKey: String? = KeychainWrapper.standard.string(forKey: "walletKey")
        if walletKey != nil {
            let wallet = Wallet(mnemonic: walletKey!, endpoint: .testnet)
            wallet.synchronise() { (error) in
                
                print("wallet.init", wallet, error)
                // Create a new transfer
                let msgTransfer = Message.transfer(symbol: "BNB", amount: self.totalPriceInCart, to: self.addressToPay, wallet: wallet)
                
                //let msg = Message.newOrder(symbol: "BNB_BTC.B-918", orderType: .limit, side: .buy, price: 100, quantity: 1, timeInForce: .goodTillExpire, wallet: wallet)
                
                // Broadcast the message
                binance.broadcast(message: msgTransfer, sync: true) { (response) in
                    SVProgressHUD.dismiss()
                    if let error = response.error { return print(error) }
                    let alertTitle = NSLocalizedString("Success", comment: "")
                    let alertMessage = NSLocalizedString("Your Transaction has been complete!", comment: "")
                    let okButtonText = NSLocalizedString("View Transaction", comment: "")
                    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: okButtonText, style: .default, handler: { (action: UIAlertAction) in
                        print(response.broadcast[0].hash)
                        UIApplication.shared.openURL(NSURL(string: "\(Constants.testnetURL)\(response.broadcast[0].hash)")! as URL)
                    }))
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            
        }
    }
    
    
    
}

