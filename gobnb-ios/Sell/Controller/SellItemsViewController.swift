//
//  SellItemsViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 19/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper
import SVProgressHUD

class SellItemsTableViewCell: UITableViewCell{
    @IBOutlet weak var cellItemImage: UIImageView!
    @IBOutlet weak var cellItemName: UILabel!
    @IBOutlet weak var cellItemDescription: UILabel!
    @IBOutlet weak var cellItemPrice: UILabel!
}

class SellItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var setupShopAlertView: UIView!
    
    @IBOutlet weak var alertViewButton: UIButton!
    @IBOutlet weak var alertViewMessage: UILabel!
    var itemsArray = [[String]]()
    var existingItemRecordId: String = "0"
    var uuid = ""
    var walletAddress = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 100
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        uuid = Helper.returnUUID().sha256()
        walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTableView()
    }
    
    @objc func refreshTableView(){
        let getItemsURL = "\(Constants.backendServerURLBase)getItems.php?uuid=\(uuid)&address=\(walletAddress)"
        fetchSellItems(url: getItemsURL)
    }
    
    func fetchSellItems(url: String){
        SVProgressHUD.show()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    self.itemsArray.removeAll()
                    SVProgressHUD.dismiss()
                    if (resultJSON[0] == "No store record"){
                        self.alertViewButton.addTarget(self, action: #selector(self.alertViewSetupStoreButtonAction), for: .touchUpInside)
                        self.tableView.backgroundView = self.setupShopAlertView
                    }else{
                        if(resultJSON[0] != "No items record"){
                            for result in resultJSON{
                                var indiResult = [String]()
                                indiResult.append(result.1["item_name"].string ?? "")
                                indiResult.append(result.1["item_description"].string ?? "")
                                indiResult.append(result.1["item_image"].string ?? "")
                                indiResult.append(result.1["price"].string ?? "")
                                indiResult.append(result.1["item_id"].string ?? "")
                                self.itemsArray.append(indiResult);
                            }
                            self.tableView.reloadData()
                        }else{
                            self.alertViewButton.setTitle("Add Item", for: .normal)
                            self.alertViewButton.removeTarget(nil, action: nil, for: .allEvents)
                            self.alertViewButton.addTarget(self, action: #selector(self.alertViewAddItemButtonAction), for: .touchUpInside)
                            self.alertViewMessage.text = "You don't have any items!"
                            self.tableView.backgroundView = self.setupShopAlertView
                        }
                    }
                    self.tableView.refreshControl?.endRefreshing()
                }else{
                    SVProgressHUD.dismiss()
                    let alert = Helper.presentAlert(title: "Error", description: "Could not load items from the remote server. Please try again later!", buttonText: "Close")
                    self.present(alert, animated: true)
                    print("error in response")
                }
        }
    }
    
    
    
    //MARK:- TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellItemsCell", for: indexPath)
        let items = itemsArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel?.text = items[0]
        cell.detailTextLabel?.text = NSLocalizedString("\(items[1])", comment: "")
        if (indexPath.row % 2 == 0){
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.7215686275, blue: 0.5803921569, alpha: 1)
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else{
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        existingItemRecordId = itemsArray[indexPath.item][4]
        performSegue(withIdentifier: "goToEditItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToEditItem" {
            if segue.destination is AddEditItemViewController
            {
                let vc = segue.destination as? AddEditItemViewController
                vc?.existingItemRecordId = existingItemRecordId
            }
        }
    }
    
    @objc func alertViewAddItemButtonAction (){
        performSegue(withIdentifier: "goToAddItem", sender: self)
    }
    
    
    @objc func alertViewSetupStoreButtonAction (){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "YourStoreVC") as? UIViewController {
            self.present(viewController, animated: true)
        }
    }
    

}
