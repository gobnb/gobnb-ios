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
import Alamofire
import SwiftyJSON

class PaymentItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemQty: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
}

class OrderProgressAndPaymentViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var hideCountDownConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countdown: CountdownLabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    
    var ordersViewType = "" //passed while calling this from OrdersViewController
    var orderId = "" //if coming from "Your Buy Orders" or "Your Sell Orders", this will have a value
    var paymentToCharge : Double = 0.00
    var currencySymbol : String = ""
    var totalItemsInCart : Int = 0
    var addressToPay:String = ""
    var ordersArray = [ShoppingItemModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65.0
        
        
        if(orderId != ""){
            //if the user is coming from "Your Buy Order" or "Your Sell Order" we will need to do a server round-trip with the orderId
            let uuid = Constants.basicUUID.sha256()
            let walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
            SVProgressHUD.show()
            let addressToQuery = "\(Constants.backendServerURLBase)getOrders.php?address=\(walletAddress)&uuid=\(uuid)&buy_or_sell=\(ordersViewType)&fetch_type=orderDetails&orderId=\(orderId)"
            fetchOrders(url: addressToQuery)
        }else{
            countdown.setCountDownTime(minutes: 60*30)
            countdown.start()
            ordersArray = ShoppingCartModel.shoppingCartArray //re-using cart item instead of doing a server query if the user is just coming from the shopping cart
        }
    }
    
    func fetchOrders(url: String){
        var orderTime = 0.00
        var paymentDone = 0
        var paymentAddress = ""
        var orderCurrency = ""
        var orderTotal = 0.00
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    if(resultJSON[0] != "No orders"){
                        for result in resultJSON{
                            print(result)
                            for item in result.1 {
                                let orderItem = ShoppingItemModel(id:item.1["item_id"].string ?? "", item_id: item.1["item_id"].string ?? "", name: item.1["item_name"].string ?? "", qty: item.1["item_qty"].intValue, price: item.1["item_price"].doubleValue )
                                self.ordersArray.append(orderItem)
                            }
                            if result.0 == "order_time"{
                                orderTime = result.1.doubleValue
                                
                            }else if (result.0 == "payment_done"){
                                paymentDone = result.1.intValue
                            }else if (result.0 == "payment_address"){
                                paymentAddress = result.1.stringValue
                            }else if (result.0 == "order_currency"){
                                orderCurrency = result.1.stringValue
                            }else if (result.0 == "order_total"){
                                orderTotal = result.1.doubleValue
                            }
                            
                            
                        }
                        if orderTime != 0.00{
                            let secondsAgo = NSDate().timeIntervalSince1970 - Double(orderTime)
                            var countDownTime = 0.00
                            let timeLeft = 1800 - secondsAgo
                            if (timeLeft > 1800){
                                countDownTime = 0
                            }else{
                                countDownTime = timeLeft
                            }
                            self.countdown.setCountDownTime(minutes: countDownTime)
                            self.countdown.start()
                        }
                        if (paymentDone == 1){
                            self.shoppingCartView.viewCartButton.setTitle("Paid", for: .normal)
                            
                        }else{
                            self.shoppingCartView.viewCartButton.setTitle("Pay Now", for: .normal)
                            self.shoppingCartView.viewCartButton.addTarget(self, action: Selector(("paymentButtonTapped:")), for: .touchUpInside)
                        }
                        if (paymentAddress != ""){
                            self.addressToPay = paymentAddress
                        }
                        if (orderCurrency != "" && orderTotal != 0.00){
                            self.shoppingCartView.totalPrice.text = "\(orderTotal) \(orderCurrency)"
                            self.shoppingCartView.totalQty.text = "\(self.ordersArray.count)"
                            self.paymentToCharge = orderTotal
                            self.currencySymbol = orderCurrency
                        }
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }else{
                        SVProgressHUD.dismiss()
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (orderId == ""){
            paymentToCharge = UserDefaults.standard.double(forKey: "totalPriceInCart")
            totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
            currencySymbol = UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? ""
            shoppingCartView.totalPrice.text = "\(paymentToCharge) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
            shoppingCartView.totalQty.text = "\(totalItemsInCart)"
            shoppingCartView.viewCartButton.setTitle("Pay Now", for: .normal)
            shoppingCartView.viewCartButton.addTarget(self, action: Selector(("paymentButtonTapped:")), for: .touchUpInside)
            addressToPay = UserDefaults.standard.string(forKey: "peopleAddress") ?? ""
        }
    }
    
    //MARK:- TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentItemsCell", for: indexPath) as! PaymentItemTableViewCell
        //var order = ordersArray[indexPath.item]
        cell.itemLabel?.text = ordersArray[indexPath.row].name
        cell.itemQty.text = "\(ordersArray[indexPath.row].qty)"
        let updatedPriceAfterQty = "\(Double(ordersArray[indexPath.row].qty) * ordersArray[indexPath.row].price)"
        cell.itemPrice.text = "\(updatedPriceAfterQty) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if (indexPath.row % 2 == 0){
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.7215686275, blue: 0.5803921569, alpha: 1)
            cell.itemLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.itemPrice.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.itemQty.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else{
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return cell
    }
    
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
                
                //print("wallet.init", wallet, error)
                
                // Create a new transfer
                let msgTransfer = Message.transfer(symbol: self.currencySymbol, amount: self.paymentToCharge, to: self.addressToPay, wallet: wallet)
                
                //let msg = Message.newOrder(symbol: "BNB_BTC.B-918", orderType: .limit, side: .buy, price: 100, quantity: 1, timeInForce: .goodTillExpire, wallet: wallet)
                
                // Broadcast the message
                binance.broadcast(message: msgTransfer, sync: true) { (response) in
                    SVProgressHUD.dismiss()
                    if let error = response.error {
                        let alert = Helper.presentAlert(title: "Error", description: "Could not process payment. Please check if you have enough \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "") tokens in your wallet!", buttonText: "Close")
                        self.present(alert, animated: true)
                        return print(error)
                    }
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

