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

class SellItemsTableViewCell: UITableViewCell{
    @IBOutlet weak var cellItemImage: UIImageView!
    @IBOutlet weak var cellItemName: UILabel!
    @IBOutlet weak var cellItemDescription: UILabel!
    @IBOutlet weak var cellItemPrice: UILabel!
}

class SellItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var setupShopAlertView: UIView!
    
    var itemsArray = [[String]]()
    var uuid = ""
    var walletAddress = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        //tableView.backgroundView = setupShopAlertView
        
        uuid = Constants.basicUUID.sha256()
        walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
        
        let getItemsURL = "\(Constants.backendServerURLBase)getItems.php?uuid=\(uuid)&address=\(walletAddress)"
        print(getItemsURL)
        fetchSellItems(url: getItemsURL)
    }
    
    func fetchSellItems(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    
                    for result in resultJSON{
                        var indiResult = [String]()
                        print(result.1)
                        indiResult.append(result.1["item_name"].string ?? "");
                        indiResult.append(result.1["item_description"].string ?? "");
                        indiResult.append(result.1["item_image"].string ?? "");
                        indiResult.append(result.1["price"].string ?? "");
                        self.itemsArray.append(indiResult);
                    }
                    self.tableView.reloadData()
                }else{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellItemsCell", for: indexPath) as! SellItemsTableViewCell
        var items = itemsArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.cellItemName.text = items[0]
        cell.cellItemDescription.text = NSLocalizedString("\(items[1])", comment: "")
        cell.cellItemPrice.text = "\(items[3])"
        cell.cellItemName.sizeToFit()
        cell.cellItemDescription.sizeToFit()
        //cell.itemPrice.sizeToFit()
        cell.backgroundColor = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        Alamofire.request(Constants.backendServerURLBase + Constants.itemsImageBaseFolder + items[2] ).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.cellItemImage.image = image
                //cell.thumbnailImage.image = image
            } else {
                print("Data is nil. I don't know what to do :(")
            }
        }
        return cell
    }
    

}
