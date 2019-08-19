//
//  OrdersViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 18/08/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class OrdersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    var walletAddress = ""
    var ordersArray = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 100
        topNavigation.title = "Your Buy Orders"
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
                    
                    for result in resultJSON{
                        var indiResult = [String]()
                        indiResult.append(result.1["order_id"].string ?? "");
                        indiResult.append(result.1["order_total"].string ?? "");
                        indiResult.append(result.1["order_currency"].string ?? "");
                        indiResult.append(result.1["order_time"].string ?? "");
                        self.ordersArray.append(indiResult);
                    }
                    print(self.ordersArray)
                    self.tableView.reloadData()
                }
        }
    }
    
    //MARK:- TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordersCell", for: indexPath)
        var order = ordersArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel?.text = "\(order[1]) \(order[2])"
        let date = Date(timeIntervalSince1970: Double(order[3]) as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        cell.detailTextLabel?.text = NSLocalizedString("\(strDate)", comment: "")
        if (indexPath.row % 2 == 0){
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.7215686275, blue: 0.5803921569, alpha: 1)
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else{
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return cell
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
