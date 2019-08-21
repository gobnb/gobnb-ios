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
import SVProgressHUD

class OrdersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    var ordersViewType = "" //passed while calling this vc from menu
    var ordersArray = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 100
        if (ordersViewType == "sell"){
            topNavigation.title = "Your Sell Orders"
        }else {
            topNavigation.title = "Your Buy Orders"
        }
        let uuid = Constants.basicUUID.sha256()
        let walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
        let addressToQuery = "\(Constants.backendServerURLBase)getOrders.php?address=\(walletAddress)&uuid=\(uuid)&buy_or_sell=\(ordersViewType)&fetch_type=orderList"
        fetchOrders(url: addressToQuery)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show()
    }
    
    
    func fetchOrders(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    if(resultJSON[0] != "No orders"){
                        for result in resultJSON{
                            var indiResult = [String]()
                            indiResult.append(result.1["order_id"].string ?? "")
                            indiResult.append(result.1["order_total"].string ?? "")
                            indiResult.append(result.1["order_currency"].string ?? "")
                            indiResult.append(result.1["payment_done"].string ?? "")
                            indiResult.append(result.1["order_time"].string ?? "")
                            self.ordersArray.append(indiResult)
                        }
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }else{
                        SVProgressHUD.dismiss()
                        self.tableView.backgroundView = self.alertView
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
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
        if (order[3] == "0"){
            cell.textLabel?.text = "\(order[1]) \(order[2]) (Unpaid)"
        }else{
            cell.textLabel?.text = "\(order[1]) \(order[2])"
        }
        let date = Date(timeIntervalSince1970: Double(order[4]) as! TimeInterval)
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
        
        if (order[3] == "0"){
            cell.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.4392156863, blue: 0.3333333333, alpha: 1)
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderId = ordersArray[indexPath.item][0]
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "OrderProgressVC") as? OrderProgressAndPaymentViewController {
            viewController.ordersViewType = ordersViewType
            viewController.orderId = orderId
            present(viewController, animated: true, completion: nil)
        }
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
