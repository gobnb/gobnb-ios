//
//  OrdersViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 18/08/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Alamofire

class OrdersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topNavigation.title = "Your Buy Orders"
    }
    
    
    //MARK:- TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordersCell", for: indexPath)
        return cell
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
