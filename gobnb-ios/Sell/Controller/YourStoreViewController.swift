//
//  YourStoreViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 19/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import CropViewController
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper
import BinanceChain

class YourStoreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var addEditPictureOutlet: UIButton!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var baseCurrencyPicker: UIPickerView!
    
    @IBOutlet weak var textAreaButtonBottomConstraint: NSLayoutConstraint!
    var supportedCurrencies = [[String]]()
    //There is no 0 in the backend table. However, this variable gets the val of existing store record id if there is one
    var existingStoreRecordId: String = "0"
    //flag to let backend know if uploaded image should be kept or discarded (if its changed)
    var imageChanged = 0
    var walletAddress = ""
    var uuid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        descriptionTextArea.delegate = self
        baseCurrencyPicker.delegate = self
        baseCurrencyPicker.dataSource = self
        nameTextField.autocapitalizationType = .sentences
        walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
        uuid = Constants.basicUUID.sha256()
        let addressToQuery = "\(Constants.backendServerURLBase)getStore.php?uuid=\(uuid)&address=\(walletAddress)"
        fetchStoreInformation(url: addressToQuery)
        let fetchCurrenciesURL = "\(Constants.backendServerURLBase)getCurrencies.php?uuid=\(uuid)"
        fetchSupportedCurrencies(url: fetchCurrenciesURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @IBAction func addEditPictureButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Fetch currencies information
    func fetchSupportedCurrencies(url: String){
        SVProgressHUD.show()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    for result in resultJSON{
                        
                        //print(result.1)
                        if(result.1 != "No record"){
                            print("record")
                            var indiResult = [String]()
                            indiResult.append(result.1["currency_id"].string ?? "")
                            indiResult.append(result.1["currency_symbol"].string ?? "")
                            self.supportedCurrencies.append(indiResult)
                            self.baseCurrencyPicker.reloadAllComponents()
                            SVProgressHUD.dismiss()
                        }else{
                            let alert = Helper.presentAlert(title: "Error", description: "Could not load supported currencies from the remote server. Please try again later!", buttonText: "Close")
                            self.present(alert, animated: true)
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
                    let alert = Helper.presentAlert(title: "Error", description: "Could not load supported currencies from the remote server. Please try again later!", buttonText: "Close")
                    self.present(alert, animated: true)
                }
        }
    }
    //Fetch store information - if it exists on the server
    func fetchStoreInformation(url: String){
        SVProgressHUD.show()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    
                    for result in resultJSON{
                        
                        //print(result.1)
                        if(result.1 != "No record"){
                            let imageURL = Constants.backendServerURLBase+Constants.imageBaseFolder+result.1["image"].string!
                            self.existingStoreRecordId = result.1["id"].string ?? "0"
                            self.addEditPictureOutlet.setTitle("edit picture", for: .normal)
                            self.nameTextField.text = result.1["name"].string ?? ""
                            self.descriptionTextArea.text = result.1["description"].string ?? ""

                            //this can be later be shifted in indices and supported currencies can have their own table in the backend-db
                            let savedBaseCurrency = result.1["basecurrency"].string ?? ""
                            var currencyID = 0
                            if savedBaseCurrency == "BNB"{
                                currencyID = 0
                            }else if savedBaseCurrency == "USDSB" {
                                currencyID = 1
                            }
                            self.baseCurrencyPicker.selectRow(currencyID, inComponent: 0, animated: true)

                            //pull the image from the URL
                            Alamofire.request(imageURL).response { response in
                                if let data = response.data {
                                    let image = UIImage(data: data)
                                    self.pickedImage.image = image
                                    SVProgressHUD.dismiss()
                                    //cell.thumbnailImage.image = image
                                } else {
                                    print("Data is nil. I don't know what to do :(")
                                }
                            }
                        }else{
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
                    let alert = Helper.presentAlert(title: "Error", description: "Could not connect to the remote server. Please try again later!", buttonText: "Close")
                    self.present(alert, animated: true)
                }
        }
    }
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            //we need the image in 15:8 ratio so cropping and restricting image to this ratio
            let cropViewController = CropViewController(image: userPickedImage)
            cropViewController.delegate = self
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.aspectRatioPickerButtonHidden = true
            cropViewController.aspectRatioLockDimensionSwapEnabled = true
            cropViewController.resetButtonHidden = true
            cropViewController.rotateButtonsHidden = true
            cropViewController.customAspectRatio = CGSize(width: 15.0, height: 8.0)
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        addEditPictureOutlet.setTitle("edit picture", for: .normal)
        pickedImage.image = image
        imageChanged = 1
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        var imageDataCount = 0
        //first check selected images data count, if its 7795, that means user is using default image, discourage that
        if let imageData = pickedImage.image?.jpeg(.lowest) {
            imageDataCount = imageData.count
        }
        if pickedImage.image == nil || imageDataCount == 7795 || imageDataCount < 200 || nameTextField.text == "" || descriptionTextArea.text.isEmpty {
            let alert = Helper.presentAlert(title: "Error", description: "All input fields are required!", buttonText: "OK")
            self.present(alert, animated: true)
        }else{
            SVProgressHUD.show()
            let helper = Helper()
            let fileName = helper.randomString(length: 30)
            let baseCurrencyPicked = supportedCurrencies[self.baseCurrencyPicker.selectedRow(inComponent: 0)]
            var baseCurrencyPickedId = ""
            for currency in supportedCurrencies {
                if currency[1] == baseCurrencyPicked[1] {
                    baseCurrencyPickedId = currency[0]
                }
            }
            if let imageData = pickedImage.image?.jpeg(.lowest) {
                let name = self.nameTextField.text
                let parameters = ["existingStoreRecordId": self.existingStoreRecordId, "name" : name!, "desc": self.descriptionTextArea.text!, "address": walletAddress, "uuid": uuid, "basecurrency": baseCurrencyPickedId, "imageChanged": self.imageChanged] as [String : Any]
                requestWith(url: "\(Constants.backendServerURLBase)insertStore.php", imageData: imageData, parameters: parameters, fileName: fileName)
            }
            
                    
                
        }
    }
        
    
    
    //PickerView functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportedCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportedCurrencies[row][1]
    }
    
    
    
    //MARK:-- Upload Functions
    
    func requestWith(url: String, imageData: Data?, parameters: [String : Any], fileName: String, onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "fileToUpload", fileName: "\(fileName).png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let json = response.data {
                        do{
                            let data = try JSON(data: json)
                            if(data[0] != "Inserted Record"){
                                let alert = Helper.presentAlert(title: "Error", description: "Could not save changes, please try again!", buttonText: "Close")
                                self.present(alert, animated: true)
                                
                            }else{
                                let alert = Helper.presentAlert(title: "Success", description: "We have successfully saved your store information!", buttonText: "OK")
                                self.present(alert, animated: true)
                            }
                        }
                        catch{
                            let alert = Helper.presentAlert(title: "Error", description: "Could not save changes, please try again!", buttonText: "Close")
                            self.present(alert, animated: true)
                            print("JSON Error")
                        }
                        
                    }
                   
                    SVProgressHUD.dismiss()
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(nil)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
                let alert = Helper.presentAlert(title: "Error", description: "Could not connect to the remote server. Please try again later!", buttonText: "Close")
                self.present(alert, animated: true)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    //Mark:- Keyboard Functions
    
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
            let keyboardHeight = newHeight  + 50 // **10 is bottom margin of View**  and **this newHeight will be keyboard height**
            print(keyboardHeight)
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            //self.textAreaOutlet.frame.origin.y = keyboardHeight
                            self.textAreaButtonBottomConstraint.constant = 10
                            //self.view.textAreaBottomConstraint = keyboardHeight
                            self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func keyboardWillHide(){
        print("keyboard hidden")
        
        UIView.animate(withDuration: 0.2,
                       delay: TimeInterval(0),
                       options: UIView.AnimationOptions(rawValue: 1),
                       animations: {
                        //self.textAreaOutlet.frame.origin.y = keyboardHeight
                        self.textAreaButtonBottomConstraint.constant = 208
                        //self.view.textAreaBottomConstraint = keyboardHeight
                        self.view.layoutIfNeeded() },
                       completion: nil)
    }
    
    //MARK:- String Prune Functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 30
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 30
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
