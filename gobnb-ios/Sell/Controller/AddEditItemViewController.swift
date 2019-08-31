//
//  AddEditItemViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 29/07/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import CropViewController
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper
import BinanceChain

class AddEditItemViewController: UIViewController, UIImagePickerControllerDelegate, CropViewControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var addEditPictureOutlet: UIButton!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    @IBOutlet weak var textAreaButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var baseCurrencyLabel: UILabel!
    
    //There is no 0 in the backend table. However, this variable gets the val of existing store record id if there is one
    var existingItemRecordId: String = "0"
    
    //flag to let backend know if uploaded image should be kept or discarded (if its changed)
    var imageChanged = 0
    var walletAddress = ""
    var uuid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        itemPriceTextField.delegate = self
        nameTextField.tag = 1
        itemPriceTextField.tag = 2
        descriptionTextArea.delegate = self
        nameTextField.autocapitalizationType = .sentences
        itemPriceTextField.keyboardType = UIKeyboardType.decimalPad
        walletAddress = KeychainWrapper.standard.string(forKey: "walletAddress")!
        uuid = Helper.returnUUID().sha256()
        print(existingItemRecordId)
        if (existingItemRecordId != "0") {
            let itemToQuery = "\(Constants.backendServerURLBase)getItem.php?uuid=\(uuid)&item=\(existingItemRecordId)"
            fetchItemInformation(url: itemToQuery)
        }
        let fetchBaseCurrencyURL = "\(Constants.backendServerURLBase)getBaseCurrency.php?uuid=\(uuid)&address=\(walletAddress)"
        fetchSupportedBaseCurrency(url: fetchBaseCurrencyURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK:- String Prune Functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        print(textField.tag)
        
        var returnCount = 0
        switch textField.tag {
            
        case 1:
            returnCount = 30
        case 2:
            returnCount = 4
        default:
            returnCount = 30
        }
        
        return updatedText.count <= returnCount
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 60
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
    
    //Fetch store base currency
    func fetchSupportedBaseCurrency(url: String){
        SVProgressHUD.show()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    for result in resultJSON{
                        if(result.1 != "No record"){
                            SVProgressHUD.dismiss()
                            self.baseCurrencyLabel.text = result.1["currency_symbol"].string ?? ""
                        }else{
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                    
                }
        }
    }
    
    //Fetch store information - if it exists on the server
    func fetchItemInformation(url: String){
        SVProgressHUD.show()
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)

                    for result in resultJSON{
                        
                        if(result.1 != "No record"){
                            let imageURL = Constants.backendServerURLBase+Constants.itemsImageBaseFolder+result.1["item_image"].string!
                            //self.existingItemRecordId = result.1["item_id"].string ?? "0"
                            self.addEditPictureOutlet.setTitle("edit picture", for: .normal)
                            self.title = "Edit Item"
                            self.nameTextField.text = result.1["item_name"].string ?? ""
                            self.descriptionTextArea.text = result.1["item_description"].string ?? ""
                            self.itemPriceTextField.text = result.1["price"].string ?? ""

                            //pull the image from the URL
                            Alamofire.request(imageURL).response { response in
                                if let data = response.data {
                                    let image = UIImage(data: data)
                                    self.pickedImage.image = image
                                    SVProgressHUD.dismiss()
                                } else {
                                    print("Data is nil. I don't know what to do :(")
                                }
                            }
                            SVProgressHUD.dismiss()
                        }else{
                            SVProgressHUD.dismiss()
                        }

                    }

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
        self.view.endEditing(true)
        keyboardWillHide()
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
            if let imageData = pickedImage.image?.jpeg(.lowest) {
                let name = self.nameTextField.text
                let parameters = ["existingItemRecordId": self.existingItemRecordId, "name" : name!, "desc": self.descriptionTextArea.text!, "address": walletAddress, "price": self.itemPriceTextField.text ?? "0.00", "uuid": uuid, "imageChanged": self.imageChanged] as [String : Any]
                requestWith(url: "\(Constants.backendServerURLBase)insertItem.php", imageData: imageData, parameters: parameters, fileName: fileName)
            }
            
        }
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
                            print("printing data")
                            print(data)
                            if(data[0] != "Inserted Record"){
                                let alert = Helper.presentAlert(title: "Error", description: "Could not save changes, please try again!", buttonText: "Close")
                                self.present(alert, animated: true)
                                
                            }else{
//                                print("data count")
//                                print(data.count)
                                if (data.count > 1) {
                                    self.existingItemRecordId = data[1].stringValue
                                    self.title = "Edit Item"
                                }
                                let alert = Helper.presentAlert(title: "Success", description: "We have successfully saved item information!", buttonText: "OK")
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
    
    
}


