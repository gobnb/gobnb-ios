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
import SVProgressHUD
import SwiftKeychainWrapper

class peopleTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let testnet = "https://testnet-explorer.binance.org/tx/"
    let binance = BinanceChain(endpoint: .testnet)
    var peopleArray = [[String]]()
    var peopleAddress:String = ""
    
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorStyle = .none
        tableView.rowHeight = 200
        SVProgressHUD.show()
        //let uuid = Constants.basicUUID.sha256()
        let uuid = Helper.returnUUID().sha256()
        fetchPeople(url: "\(Constants.backendServerURLBase)index.php?uuid=\(uuid)")
        //getWallet();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //View cart subview at the bottom funcationality
        if ShoppingCartModel.shoppingCartArray.isEmpty {
            shoppingCartView.isHidden = true
        }else{
            let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
            let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
            shoppingCartView.totalPrice.text = "\(totalPriceInCart) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
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
    
    func fetchPeople(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    
                    for result in resultJSON{
                        var indiResult = [String]()
                        //print(result.1["place"])
                        indiResult.append(result.1["name"].string ?? "");
                        indiResult.append(result.1["description"].string ?? "");
                        indiResult.append(result.1["image"].string ?? "");
                        indiResult.append(result.1["address"].string ?? "");
                        self.peopleArray.append(indiResult);
                    }
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }else{
                    SVProgressHUD.dismiss()
                    let alertMessage = "Error"
                    let message = "Could not connect to the server, please try again later!"
                    let alert = UIAlertController(title: alertMessage, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { _ in
                        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "walletKey")
                        if removeSuccessful {
                            let sb:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                            let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
                            self.present(vc1, animated: true, completion: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion:nil)
                    
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCellMain", for: indexPath) as! peopleTableViewCell
        var people = peopleArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.placeLabel.text = people[0]
        cell.descriptionLabel.text = NSLocalizedString("\(people[1])", comment: "")
        cell.placeLabel.sizeToFit()
        cell.descriptionLabel.sizeToFit()
        cell.backgroundColor = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        print(Constants.backendServerURLBase + Constants.imageBaseFolder + people[2])
        Alamofire.request(Constants.backendServerURLBase + Constants.imageBaseFolder + people[2]).response { response in
            if let data = response.data {
                print(data)
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
        let tappedItem = peopleArray[indexPath.item]
        peopleAddress = tappedItem[3]
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ItemsTableViewController
        {
            let vc = segue.destination as? ItemsTableViewController
            vc?.peopleAddress = peopleAddress
        }
    }
    
    
    func getWallet(){
        
        let walletKey = KeychainWrapper.standard.string(forKey: "walletKey") ?? ""
        print("wallet key is here")
        print(walletKey)
        // Restore with a mnemonic phrase
        let wallet = Wallet(mnemonic: walletKey, endpoint: .testnet)

        // Access keys
//        print(wallet.privateKey)
//        print(wallet.publicKey)
//        print(wallet.mnemonic)
//        print(wallet.account)
//        print(wallet.address)
        KeychainWrapper.standard.set(wallet.account, forKey: "walletAddress")
        // Synchronise with the remote node before using the wallet
        wallet.synchronise() { (error) in
            
            if let error = error {
                
                let alert = Helper.presentAlert(title: "Error", description: "Could not load wallet, please try again!", buttonText: "Close")
                self.present(alert, animated: true, completion: {
                    let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "walletKey")
                    print(removeSuccessful)
                    //Log out should happen here
                    
                })
                return print(error)
            }

            // Generate a new order ID
            //let id = wallet.nextAvailableOrderId()

            // Sign a message
            //let data = wallet.sign(message: data)

            // Access details
//            print(wallet.accountNumber)
//            print(wallet.sequence)

        }
    }

    

}

