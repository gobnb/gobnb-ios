//
//  YourStoreViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 19/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit

class YourStoreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var baseCurrencyPicker: UIPickerView!
    let supportedCurrencies = ["BNB", "USDSB"]
    override func viewDidLoad() {
        super.viewDidLoad()
        baseCurrencyPicker.delegate = self
        baseCurrencyPicker.dataSource = self
    }
    
    @IBAction func addEditPictureButtonTapped(_ sender: Any) {
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
    }
    
    //PickerView functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportedCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportedCurrencies[row]
    }
    

}
