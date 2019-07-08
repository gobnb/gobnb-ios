//
//  ShoppingCartViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 03/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

protocol CartItemTableViewCellDelegate {
    func addButtonPressed(qty: String)
    func subtractButtonPressed(qty: String)
}

class CartItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    var idOfTheRecord : String = ""
    
    var delegate: CartItemTableViewCellDelegate?
    @IBAction func subtractButtonDidPress(_ sender: Any) {
        let newQty = Int(qtyLabel.text!)! - 1
        if(newQty > 0){
            qtyLabel.text = "\(newQty)"
            
            var i = 0;
            for var item in ShoppingCartModel.shoppingCartArray
            {
                if item.id == idOfTheRecord {
                    item.qty = item.qty - 1
                    itemPriceLabel.text = "\(Double(item.qty) * item.price) BNB"
                    ShoppingCartModel.shoppingCartArray[i] = item
                    break
                }
                i = i+1;
            }
            Helper().updateCartPriceAndQty() //update global cart user defaults
            
        }
        //delegate?.subtractButtonPressed(qty: qtyLabel.text ?? "0")
    }
    
    @IBAction func addButtonDidPress(_ sender: Any) {
        let newQty = Int(qtyLabel.text!)! + 1
        if(newQty < 10){
            qtyLabel.text = "\(newQty)"
            
            var i = 0;
            for var item in ShoppingCartModel.shoppingCartArray
            {
                if item.id == idOfTheRecord {
                    item.qty = item.qty + 1
                    itemPriceLabel.text = "\(Double(item.qty) * item.price) BNB"
                    ShoppingCartModel.shoppingCartArray[i] = item
                    break
                }
                i = i+1;
            }
            Helper().updateCartPriceAndQty() //update global cart user defaults
        }
        //delegate?.addButtonPressed(qty: qtyLabel.text ?? "0")
    }
    
    
}

class ShoppingCartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CartItemTableViewCellDelegate {
    
    
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
        cell.idOfTheRecord = ShoppingCartModel.shoppingCartArray[indexPath.row].id
        cell.itemNameLabel.text = ShoppingCartModel.shoppingCartArray[indexPath.row].name
        cell.qtyLabel.text = "\(ShoppingCartModel.shoppingCartArray[indexPath.row].qty)"
        let updatedPriceAfterQty = "\(Double(ShoppingCartModel.shoppingCartArray[indexPath.row].qty) * ShoppingCartModel.shoppingCartArray[indexPath.row].price)"
        cell.itemPriceLabel.text = "\(updatedPriceAfterQty) BNB"
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func addButtonPressed(qty:String) {
        let alertMessage = "\(qty) Add Pressed"
        let message = "Let's watch it later"
        let alert = UIAlertController(title: alertMessage, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func subtractButtonPressed(qty:String) {
        let alertMessage = "\(qty) Subtract Pressed"
        let message = "Let's watch it later"
        let alert = UIAlertController(title: alertMessage, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
