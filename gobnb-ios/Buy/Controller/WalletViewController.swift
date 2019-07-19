//
//  WalletViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 18/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import BinanceChain
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper

class WalletViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let testnet = "https://testnet-explorer.binance.org/tx/"
    let binance = BinanceChain(endpoint: .testnet)
    var transactionsArray = [[String]]()
    @IBOutlet weak var tokenBalance: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var walletAddress:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorStyle = .none
        walletAddress = UserDefaults.standard.string(forKey: "walletAddress") ?? ""
        print(walletAddress)
        SVProgressHUD.show()
        getAccount()
        getTransactions()
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    func getAccount(){
        binance.account(address: walletAddress) { (response) in
            //print(response.account.balances)
            let balances = response.account.balances
            for balance in balances{
                print(balance.free.toString())
                if(balance.symbol == "BNB"){
                    
                    self.tokenBalance.text = "BNB Balance: \(String(format:"%.5f", balance.free))"
                    self.tokenBalance.sizeToFit()
                }
            }
        }
    }
    
    func getTransactions(){
        
        // Get transactions for an address
        binance.transactions(address: walletAddress) { (response) in
            //print(response.transactions.tx)
            let transactionList = response.transactions.tx
            for transaction in transactionList{
                if(transaction.toAddr != ""){
                    //print(transaction.toAddr)
                    var transactionsDetail = [String]()
                    transactionsDetail.append("\(transaction.txAsset) \(transaction.value)")
                    transactionsDetail.append(transaction.txHash)
                    self.transactionsArray.append(transactionsDetail)
                }
            }
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)
        var transaction = transactionsArray[indexPath.item]
        cell.textLabel?.text = transaction[0]
        cell.detailTextLabel?.text = NSLocalizedString("Tx: \(transaction[1])", comment: "")
        cell.backgroundColor = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        UIApplication.shared.openURL(NSURL(string: "\(testnet)\(transactionsArray[indexPath.row][1])")! as URL)
    }

    @IBAction func logOutPressed(_ sender: Any) {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "walletKey")
        if removeSuccessful {
            let sb:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
            self.present(vc1, animated: true, completion: nil)
        }
    }
}
