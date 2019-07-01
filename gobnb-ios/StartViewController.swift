//
//  StartViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 19/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class StartViewController: UIViewController {

   
    
    @IBOutlet weak var textAreaButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textAreaOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        /textAreaOutlet.delegate = self
        print("start")
        //checkWallet()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        checkWallet()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func checkWallet(){
        let walletKey: String? = KeychainWrapper.standard.string(forKey: "walletKey")
        if((walletKey) != nil){
            performSegue(withIdentifier: "goToScan", sender: nil)
        }
    }

    @IBAction func submitPressed(_ sender: Any) {
        print(textAreaOutlet.text as! String)
        let saveSuccessful: Bool = KeychainWrapper.standard.set(textAreaOutlet.text, forKey: "walletKey")
        if saveSuccessful {
            performSegue(withIdentifier: "goToFeed", sender: self)
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
        print("keyboard is showing")
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

