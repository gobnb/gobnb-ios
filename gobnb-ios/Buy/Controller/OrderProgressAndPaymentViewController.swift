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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countdown: CountdownLabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    var totalPriceInCart : Double = 0.00
    var totalItemsInCart : Int = 0
    var addressToPay:String = ""
    var ordersArray = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65.0
        countdown.setCountDownTime(minutes: 60*30)
        countdown.start()
        let uuid = Constants.basicUUID.sha256()
        let walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
        let addressToQuery = "\(Constants.backendServerURLBase)getOrders.php?address=\(walletAddress)&uuid=\(uuid)&buy_or_sell=buy"
        fetchOrders(url: addressToQuery)
        }
    
    func fetchOrders(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    if(resultJSON[0] != "No orders"){
                        for result in resultJSON{
                            var indiResult = [String]()
                            indiResult.append(result.1["order_id"].string ?? "");
                            indiResult.append(result.1["order_total"].string ?? "");
                            indiResult.append(result.1["order_currency"].string ?? "");
                            indiResult.append(result.1["payment_done"].string ?? "");
                            indiResult.append(result.1["order_time"].string ?? "");
                            self.ordersArray.append(indiResult);
                            SVProgressHUD.dismiss()
                            self.tableView.reloadData()
                        }
                    }else{
                        SVProgressHUD.dismiss()
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
        totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
        shoppingCartView.totalPrice.text = "\(totalPriceInCart) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
        shoppingCartView.totalQty.text = "\(totalItemsInCart)"
        shoppingCartView.viewCartButton.setTitle("Pay Now", for: .normal)
        shoppingCartView.viewCartButton.addTarget(self, action: Selector(("paymentButtonTapped:")), for: .touchUpInside)
        addressToPay = UserDefaults.standard.string(forKey: "peopleAddress") ?? ""
    }
    
    //MARK:- TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShoppingCartModel.shoppingCartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentItemsCell", for: indexPath) as! PaymentItemTableViewCell
        //var order = ordersArray[indexPath.item]
        cell.itemLabel?.text = ShoppingCartModel.shoppingCartArray[indexPath.row].name
        cell.itemQty.text = "\(ShoppingCartModel.shoppingCartArray[indexPath.row].qty)"
        let updatedPriceAfterQty = "\(Double(ShoppingCartModel.shoppingCartArray[indexPath.row].qty) * ShoppingCartModel.shoppingCartArray[indexPath.row].price)"
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
                let currencySymbol = UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? ""
                // Create a new transfer
                let msgTransfer = Message.transfer(symbol: currencySymbol, amount: self.totalPriceInCart, to: self.addressToPay, wallet: wallet)
                
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

