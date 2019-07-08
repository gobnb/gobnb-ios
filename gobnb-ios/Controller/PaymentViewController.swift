//
//  PaymentViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 18/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Alamofire
import BinanceChain
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper

class PaymentViewController: UIViewController {
    let testnet = "https://testnet-explorer.binance.org/tx/"
    
    @IBOutlet weak var shoppingCartCounterLabel: UILabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    @IBOutlet weak var titleOfItem: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    
    
    var itemArray = [String]()
    var addressToPay:String = ""
    var totalPrice:Double?
    var cartCounter: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillDetails()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        showShoppingCartView()
        
        
        
    }
    
    func fillDetails(){
        titleOfItem.text = itemArray[0]
        itemPrice.text = "\(itemArray[3]) BNB"
        addressToPay = itemArray[4]
        totalPrice = Double(itemArray[3])
        Alamofire.request(itemArray[2]).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                self.itemImageView.image = image
            } else {
                print("Data is nil. I don't know what to do :(")
            }
        }
    }
    
    func showShoppingCartView(){
        if ShoppingCartModel.shoppingCartArray.isEmpty {
            shoppingCartView.isHidden = true
        }else{
            let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
            let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
            shoppingCartView.totalPrice.text = "\(totalPriceInCart) BNB"
            shoppingCartView.totalQty.text = "\(totalItemsInCart)"
            shoppingCartView.viewCartButton.addTarget(self, action: Selector(("cartButtonTapped:")), for: .touchUpInside)
            shoppingCartView.isHidden = false
        }
    }
    
    // BUTTON ACTIONS
    
    @IBAction func subtractItemAction(_ sender: Any) {
        if cartCounter != 1 {
            cartCounter = cartCounter - 1
            shoppingCartCounterLabel.text = "\(cartCounter)"
        }
    }
    
    @IBAction func plusItemAction(_ sender: Any) {
        if cartCounter != 9 {
            cartCounter = cartCounter + 1
            shoppingCartCounterLabel.text = "\(cartCounter)"
        }
        
        
        showShoppingCartView()
    }
    
    @IBAction func addToCartButtonPressed(_ sender: Any) {
        //get and assign a random ID
        let helper = Helper()
        let randomId = helper.randomString(length: 19)
        
        // First see if item already exists in the cart, if yes, lets just update it
        var i = 0;
        var itemFound = 0;
        for var item in ShoppingCartModel.shoppingCartArray
        {
            if item.name == titleOfItem.text! {
                item.qty = item.qty + cartCounter
                ShoppingCartModel.shoppingCartArray[i] = item
                itemFound = 1
                break
            }
            i = i+1;
        }
        
        if itemFound == 0 {
            //we are adding qty but storing individual price of item in the array
            //later we just multiply the price with qty wherever we need it
            let shoppingCartItem = ShoppingItemModel(id: randomId, name: titleOfItem.text!, qty: cartCounter, price: totalPrice ?? 0.00)
            ShoppingCartModel.shoppingCartArray.append(shoppingCartItem)
        }
        
        helper.updateCartPriceAndQty()
        let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
        let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
        shoppingCartView.totalPrice.text = "\(totalPriceInCart) BNB"
        shoppingCartView.totalQty.text = "\(totalItemsInCart)"
        
        shoppingCartView.viewCartButton.addTarget(self, action: Selector(("cartButtonTapped:")), for: .touchUpInside)
        showShoppingCartView()
    }
    
    @objc func cartButtonTapped(_ sender: UIButton){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingCartVC") as? UIViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        let binance = BinanceChain(endpoint: .testnet)
        let walletKey: String? = KeychainWrapper.standard.string(forKey: "walletKey")
        if walletKey != nil {
        let wallet = Wallet(mnemonic: walletKey!, endpoint: .testnet)
            wallet.synchronise() { (error) in
                
                print("wallet.init", wallet, error)
                // Create a new transfer
                let amount : Double = self.totalPrice ?? 0.00
                let msgTransfer = Message.transfer(symbol: "BNB", amount: amount, to: self.addressToPay, wallet: wallet)
                
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
                        UIApplication.shared.openURL(NSURL(string: "\(self.testnet)\(response.broadcast[0].hash)")! as URL)
                    }))
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        
        }
    }
    
    func transactionSuccess(){
        print("pohanch hi gaye")
    }
    
}
