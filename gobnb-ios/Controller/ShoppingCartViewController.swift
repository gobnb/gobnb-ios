//
//  ShoppingCartViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 03/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var itemPriceLabel: UILabel!
}

class ShoppingCartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    @IBOutlet weak var itemsTableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        itemsTableView.frame = CGRect(x: itemsTableView.frame.origin.x, y: itemsTableView.frame.origin.y, width: itemsTableView.frame.size.width, height: itemsTableView.contentSize.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        itemsTableView.frame = CGRect(x: itemsTableView.frame.origin.x, y: itemsTableView.frame.origin.y, width: itemsTableView.frame.size.width, height: itemsTableView.contentSize.height)
    }


    
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShoppingCartModel.shoppingCartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartItemCell", for: indexPath) as! CartItemTableViewCell
        //cell.itemNameLabel.text = itemArray[indexPath.row]
        cell.itemNameLabel.text = ShoppingCartModel.shoppingCartArray[indexPath.row].name
        cell.qtyLabel.text = "\(ShoppingCartModel.shoppingCartArray[indexPath.row].qty)"
        cell.itemPriceLabel.text = "\(ShoppingCartModel.shoppingCartArray[indexPath.row].price) BNB"
        return cell
    }
    

}
