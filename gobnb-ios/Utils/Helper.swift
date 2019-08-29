//
//  Helper.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 04/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func updateCartPriceAndQty(){
        var totalPriceInCart:Double = 0.00
        var totalItemsInCart:Int = 0
        for i in 0..<ShoppingCartModel.shoppingCartArray.count {
            let oneItemIntoQty = ShoppingCartModel.shoppingCartArray[i].price * Double(ShoppingCartModel.shoppingCartArray[i].qty)
            totalPriceInCart = oneItemIntoQty + totalPriceInCart
            totalItemsInCart = ShoppingCartModel.shoppingCartArray[i].qty + totalItemsInCart
        }
        totalPriceInCart = totalPriceInCart.roundToDecimal(3)
        UserDefaults.standard.set(totalPriceInCart, forKey: "totalPriceInCart")
        UserDefaults.standard.set(totalItemsInCart, forKey: "totalItemsInCart")
    }
    
    static func emptyTheCart(){
        ShoppingCartModel.shoppingCartArray.removeAll()
        UserDefaults.standard.set(0.00, forKey: "totalPriceInCart")
        UserDefaults.standard.set(0, forKey: "totalItemsInCart")
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func presentAlert(title: String, description: String, buttonText: String) -> UIAlertController{
        let alertTitle = NSLocalizedString(title, comment: "")
        let alertMessage = NSLocalizedString(description, comment: "")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
        return alert
    }
    
}
extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
