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

    @IBOutlet weak var textAreaOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start")
        //checkWallet()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWallet()
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
    
}
