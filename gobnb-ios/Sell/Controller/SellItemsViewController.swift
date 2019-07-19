//
//  SellItemsViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 19/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

class SellItemsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var setupShopAlertView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.separatorStyle = .none
        tableView.backgroundView = setupShopAlertView
    }
    
    

}
