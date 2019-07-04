//
//  ViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 17/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import BinanceChain
import Alamofire
import SwiftyJSON

class DealsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let testnet = "https://testnet-explorer.binance.org/tx/"
    let binance = BinanceChain(endpoint: .testnet)
    var dealsArray = [[String]]()
    var dealAddress:String = ""
    
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorStyle = .none
        tableView.rowHeight = 200
        
        fetchDeals(url: Obfuscator().reveal(key: Constants.backendServerURL))
        
        //testTransaction();
        //testBinance();
        getWallet();
        //testBroadcastControl();
        //testNodeRPC();
        //getTransactions();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //View cart subview at the bottom funcationality
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
    
    @objc func cartButtonTapped(_ sender: UIButton){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingCartVC") as? UIViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func fetchDeals(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    
                    for result in resultJSON{
                        var indiResult = [String]()
                        //print(result.1["place"])
                        indiResult.append(result.1["place"].string ?? "");
                        indiResult.append(result.1["description"].string ?? "");
                        indiResult.append(result.1["image"].string ?? "");
                        indiResult.append(result.1["address"].string ?? "");
                        self.dealsArray.append(indiResult);
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCellMain", for: indexPath) as! DealsTableViewCell
        var deals = dealsArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.placeLabel.text = deals[0]
        cell.descriptionLabel.text = NSLocalizedString("\(deals[1])", comment: "")
        cell.placeLabel.sizeToFit()
        cell.descriptionLabel.sizeToFit()
        cell.backgroundColor = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        Alamofire.request(deals[2]).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.placeImage.image = image
                //cell.thumbnailImage.image = image
            } else {
                print("Data is nil. I don't know what to do :(")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(dealsArray[indexPath.item])
        let deal = dealsArray[indexPath.item]
        dealAddress = deal[3]
        performSegue(withIdentifier: "goToItems", sender: self)
        //navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ItemsTableViewController
        {
            let vc = segue.destination as? ItemsTableViewController
            vc?.peopleAddress = dealAddress
        }
    }
    
    
    //TEST FUNCTIONS FOR BINANCE CHAIN
    
    func getTransactions(){
        let binance = BinanceChain(endpoint: .testnet)
        // Get transactions for an address
        binance.transactions(address: "tbnb1yqyppmev2m4z96r4svwtjq8eqp653pt6elq33r") { (response) in
//            /print(response.transactions)
        }
    }
    
    public func testBroadcastControl(endpoint: BinanceChain.Endpoint = .testnet) {
        
        // Run a broadcast control test
        let mnemonic = "depth math nuclear wage board push system ugly movie retreat elephant valve coconut top super seek gasp rigid bitter network universe silly toast myth";
        let binance = BinanceChain(endpoint: endpoint)
        let wallet = Wallet(mnemonic: mnemonic, endpoint: .testnet)
        wallet.synchronise() { (error) in
            
            print("wallet.init", wallet, error)
            
            let symbol = "BNB_BTC.B-918"
            let type = OrderType.limit
            let side = Side.sell
            let price : Double = 0.004
            let quantity : Double = 1
            let tif = TimeInForce.goodTillExpire
            
            let msgNewOrder = Message.newOrder(symbol: symbol, orderType: type, side: side, price: price,
                                               quantity: quantity, timeInForce: tif, wallet: wallet)
            binance.broadcast(message: msgNewOrder, sync: true) { (response) in
                print("broadcast.neworder", response.transactions, response.error)
            }
            
        }
        
    }
    
    func testTransaction(){
        let binance = BinanceChain(endpoint: .testnet)
        let wallet = Wallet(mnemonic: "depth math nuclear wage board push system ugly movie retreat elephant valve coconut top super seek gasp rigid bitter network universe silly toast myth", endpoint: .testnet)
        print("han g");
        wallet.synchronise() { (error) in
            
            print("wallet.init", wallet, error)
        // Create a new transfer
        let amount : Double = 1.01
        let msgTransfer = Message.transfer(symbol: "BNB", amount: amount, to: "tbnb1mmehrux6snnuq6cq2gq4396m9lycwzy700l60a", wallet: wallet)
        
        //let msg = Message.newOrder(symbol: "BNB_BTC.B-918", orderType: .limit, side: .buy, price: 100, quantity: 1, timeInForce: .goodTillExpire, wallet: wallet)
        
        // Broadcast the message
        binance.broadcast(message: msgTransfer, sync: true) { (response) in
            if let error = response.error { return print(error) }
            print("hello");
            print(response.broadcast)
        }
        }
    }
    
    func getWallet(){
        let walletKey = UserDefaults.standard.string(forKey: "walletKey") ?? ""
        // Restore with a mnemonic phrase
        let wallet = Wallet(mnemonic: walletKey, endpoint: .testnet)

        // Access keys
        print(wallet.privateKey)
        print(wallet.publicKey)
        print(wallet.mnemonic)
        print(wallet.account)
        print(wallet.address)
        UserDefaults.standard.set(wallet.account, forKey: "walletAddress")
        // Synchronise with the remote node before using the wallet
        wallet.synchronise() { (error) in

            if let error = error { return print(error) }

            // Generate a new order ID
            let id = wallet.nextAvailableOrderId()

            // Sign a message
            //let data = wallet.sign(message: data)

            // Access details
            print(wallet.accountNumber)
            print(wallet.sequence)

        }
    }

    func testBinance(){
        print("testing binance");
    let binance = BinanceChain()
        print("testing binance");
    // Get the latest block time and current time
    binance.time() { (response) in
    if let error = response.error { return print(error) }
    print(response.time)
    }
    
//    // Get node information
//    binance.nodeInfo() { (response) in
//    print(response.nodeInfo)
//    }
//
//    // Get the list of validators used in consensus
//    binance.validators() { (response) in
//    print(response.validators)
//    }
//
//    // Get the list of network peers
//    binance.peers() { (response) in
//    print(response.peers)
//    }
//
//    // Get account metadata for an address
//    binance.account(address: "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr") { (response) in
//    //print(response.address)
//    }
//
//    // Get an account sequence
//    binance.sequence(address: "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr") { (response) in
//    print(response.sequence)
//    }
//
//    // Get a transaction
//    binance.tx(hash: "5CAA5E0C6266B3BB6D66C00282DFA0A6A2F9F5A705E6D9049F619B63E1BE43FF") { (response) in
//    print(response.tx)
//    }
    
    // Get token list
    binance.tokens(limit: .fiveHundred, offset: 0) { (response) in
    print(response.tokens)
    }
//
//    // Get market pairs
//    binance.markets(limit: .oneHundred, offset: 0) { (response) in
//    print(response.markets)
//    }
//
//    // Obtain trading fees information
//    binance.fees() { (response) in
//    print(response.fees)
//    }
//
//    // Get the order book
//    binance.marketDepth(symbol: "BNB_BTC.B-918") { (response) in
//    print(response.marketDepth)
//    }
//
//    // Get candlestick/kline bars for a symbol
//    binance.klines(symbol: "BNB_BTC.B-918", interval: .fiveMinutes) { (response) in
//    print(response.candlesticks)
//    }
//
//    // Get closed (filled and cancelled) orders for an address
//    binance.closedOrders(address: "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr") { (response) in
//    print(response.orderList)
//    }
//
//    // Get open orders for an address
//    binance.openOrders(address: "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr") { (response) in
//    print(response.orderList)
//    }
//
//    // Get an order
////    binance.order(id: hashId) { (response) in
////    print(response.order)
////    }
//
//    // Get 24 hour price change statistics for a market pair symbol
//    binance.ticker(symbol: "BNB_BTC.B-918") { (response) in
//    print(response.ticker)
//    }
//
//    // Get a list of historical trades
//    binance.trades() { (response) in
//    print(response.trades)
//    }
//
//    // Get transactions for an address
//    binance.transactions(address: "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr") { (response) in
//    print(response.transactions)
//    }
    }

}

