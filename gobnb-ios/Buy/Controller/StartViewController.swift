//
//  StartViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 19/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import BinanceChain
import SVProgressHUD

class StartViewController: UIViewController {

   
    
    @IBOutlet weak var textAreaButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textAreaOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @IBAction func submitPressed(_ sender: Any) {
        SVProgressHUD.show()
        let saveSuccessful: Bool = KeychainWrapper.standard.set(textAreaOutlet.text, forKey: "walletKey")
        if saveSuccessful {
            let wallet = Wallet(mnemonic: textAreaOutlet.text, endpoint: .testnet)
            wallet.synchronise() { (error) in
                let walletAddress = wallet.account
                let binance = BinanceChain()
                // Get account metadata for an address
                binance.account(address: walletAddress) { (response) in
                    print(response.account.publicKey)
                    if(response.account.accountNumber == 0){
                        SVProgressHUD.dismiss()
                        KeychainWrapper.standard.removeObject(forKey: "walletKey")
                        print("account is invalid")
                        let alertTitle = NSLocalizedString("Error", comment: "")
                        let alertMessage = NSLocalizedString("Could not find Binance Chain account. Please try again with correct mnemonic key!", comment: "")
                        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }else{
                        SVProgressHUD.dismiss()
                        KeychainWrapper.standard.set(walletAddress, forKey: "walletKey")
                        self.performSegue(withIdentifier: "goToScan", sender: self)
                    }
                }
            }
        }else {
            print("error")
        }
    }
    
    //
    // KEYBOARD FUNCTIONS
    //
    
    //Called when 'return' key is pressed. Return false to keep the keyboard visible.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    // Called when the user clicks on the view (outside of UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        keyboardWillHide()
    }
    
    
    
    @objc func keyboardWillShow( notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let newHeight: CGFloat
            let duration:TimeInterval = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if #available(iOS 11.0, *) {
                newHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
            } else {
                newHeight = keyboardFrame.cgRectValue.height
            }
            let keyboardHeight = newHeight  + 10 // **10 is bottom margin of View**  and **this newHeight will be keyboard height**
            print(keyboardHeight)
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            //self.textAreaOutlet.frame.origin.y = keyboardHeight
                            self.textAreaButtonBottomConstraint.constant = keyboardHeight
                            //self.view.textAreaBottomConstraint = keyboardHeight
                                self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func keyboardWillHide(){
        print("keyboard hidden")
        self.textAreaButtonBottomConstraint.constant = 125 //hard-code resetting to original constant value
    }
    
}

