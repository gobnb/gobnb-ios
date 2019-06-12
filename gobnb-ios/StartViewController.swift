//
//  StartViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 19/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

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
        let walletKey = UserDefaults.standard.string(forKey: "walletKey") ?? ""
        if(walletKey != ""){
            performSegue(withIdentifier: "goToScan", sender: nil)
        }
    }

    
}
