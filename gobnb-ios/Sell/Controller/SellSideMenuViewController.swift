//
//  SellSideMenuViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 17/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SellSideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let navArray = ["Your Store", "Your Sell Orders", "Your Wallet", "Help", "Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65.0
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "buySideNav"
        {
            print("buySideNav")
            UserDefaults.standard.set("buySideNav", forKey: "StartSideVC")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        if self.navArray.count > 0 {
            cell?.textLabel!.text = self.navArray[indexPath.row]
        }
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemAtThePath = navArray[indexPath.item]
        if itemAtThePath == "Your Store" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "YourStoreVC") as? UIViewController {
                _ = UINavigationController(rootViewController: viewController)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if itemAtThePath == "Payments" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SellPaymentsVC") as? UIViewController {
                _ = UINavigationController(rootViewController: viewController)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if itemAtThePath == "Your Sell Orders" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "YourOrdersVC") as? OrdersTableViewController {
                viewController.ordersViewType = "sell"
                present(viewController, animated: true, completion: nil)
            }
        }else if itemAtThePath == "Your Wallet" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "YourWalletVC") as? UIViewController {
                self.present(viewController, animated: true)
            }
        }else if itemAtThePath == "Help" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HelpVC") as? UIViewController {
                self.present(viewController, animated: true)
            }
        }else if itemAtThePath == "Log Out" {
            let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "walletKey")
            if removeSuccessful {
                let sb:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc1 = sb.instantiateViewController(withIdentifier: "StartViewController")
                self.present(vc1, animated: true, completion: nil)
            }
        }
    }

}
