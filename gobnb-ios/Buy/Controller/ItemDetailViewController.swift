//
//  PaymentViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 18/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Alamofire
import BinanceChain
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var shoppingCartCounterLabel: UILabel!
    @IBOutlet weak var shoppingCartView: ShoppingCartView!
    @IBOutlet weak var titleOfItem: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPrice: UILabel!
    
    
    var itemArray = [String]()
    var addressToPay:String = ""
    var totalPrice:Double?
    var cartCounter: Int = 1
    var item_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillDetails()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        showShoppingCartView()
    }
    
    //Update shopping cart subview at the bottom of the screen
    func showShoppingCartView(){
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
    
    //Fill items details since we have fetched them already, only need to fetch image again
    func fillDetails(){
        titleOfItem.text = itemArray[0]
        itemPrice.text = "\(itemArray[3]) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
        addressToPay = itemArray[5]
        totalPrice = Double(itemArray[3])
        item_id = itemArray[4]
        Alamofire.request(Constants.backendServerURLBase + Constants.itemsImageBaseFolder + itemArray[2] ).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                self.itemImageView.image = image
            } else {
                print("Data is nil. I don't know what to do :(")
            }
        }
    }
    
    
    // BUTTON ACTIONS
    
    @IBAction func subtractItemAction(_ sender: Any) {
        if cartCounter != 1 {
            cartCounter = cartCounter - 1
            shoppingCartCounterLabel.text = "\(cartCounter)"
        }
    }
    
    @IBAction func plusItemAction(_ sender: Any) {
        if cartCounter != 9 {
            cartCounter = cartCounter + 1
            shoppingCartCounterLabel.text = "\(cartCounter)"
        }
        showShoppingCartView()
    }
    
    @IBAction func addToCartButtonPressed(_ sender: Any) {
        //get and assign a random ID
        let helper = Helper()
        
        //first check if the user has an existing cart from another restaurant
        if helper.isKeyPresentInUserDefaults(key: "peopleAddress"){
            let oldPeopleAddress = UserDefaults.standard.string(forKey: "peopleAddress") ?? ""
            if oldPeopleAddress != addressToPay {
                Helper.emptyTheCart() //empty the cart by resetting all userdefaults and shoppingcartmodel array
                UserDefaults.standard.set(addressToPay, forKey: "peopleAddress")
                let alertTitle = NSLocalizedString("Changing Cart", comment: "")
                let alertMessage = NSLocalizedString("You have changed restaurant/café! We have dropped the previous cart and created a new one for you!", comment: "")
                let okButtonText = NSLocalizedString("OK", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: okButtonText, style: .default, handler: nil))
                present(alert, animated: true)
            }
        }else{
            //the key doesn't exist, add a new one
            UserDefaults.standard.set(addressToPay, forKey: "peopleAddress")
        }
        
        
        //lets add this item in the cart now
        let randomId = helper.randomString(length: 19)
        
        // First see if item already exists in the cart, if yes, lets just update it
        var i = 0;
        var itemFound = 0;
        for var item in ShoppingCartModel.shoppingCartArray
        {
            if item.name == titleOfItem.text! {
                item.qty = item.qty + cartCounter
                if(item.qty > 9){
                    item.qty = 9
                    let alert = Helper.presentAlert(title: "Error", description: "You can only add up to 9 items of each product at a time!", buttonText: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
                if(item.qty < 10 ){
                    ShoppingCartModel.shoppingCartArray[i] = item
                }
                itemFound = 1
                break
            }
            i = i+1;
        }
        
        if itemFound == 0 {
            //we are adding qty but storing individual price of item in the array
            //later we just multiply the price with qty wherever we need it
            let shoppingCartItem = ShoppingItemModel(id: randomId, item_id: item_id, name: titleOfItem.text!, qty: cartCounter, price: totalPrice ?? 0.00)
            ShoppingCartModel.shoppingCartArray.append(shoppingCartItem)
        }
        
        helper.updateCartPriceAndQty()
        let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
        let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
        shoppingCartView.totalPrice.text = "\(totalPriceInCart) \(UserDefaults.standard.string(forKey: "storeBaseCurrency") ?? "")"
        shoppingCartView.totalQty.text = "\(totalItemsInCart)"
        
        shoppingCartView.viewCartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        showShoppingCartView()
    }
    
    @objc func cartButtonTapped(_ sender: UIButton){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingCartVC") as? UIViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
}
