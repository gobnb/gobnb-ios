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

class YourStoreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var addEditPictureOutlet: UIButton!
    
    @IBOutlet weak var pickedImage: UIImageView!
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
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        print("buttontapped")
        if let imageData = pickedImage.image?.jpeg(.lowest) {
            print(imageData.count)
            //let data = UIImageJPEGRepresentation(pickedImage.image!, 1.0)
            //let data = pickedImage.image?.pngData()
            //let parameters = [String : Any]
            if(imageData.count > 1){
            let parameters = ["fName" : "hammad", "lName": "tariq"]
            requestWith(url: "http://zerobillion.com/binancepay/insertStore.php", imageData: imageData, parameters: parameters)
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
        return supportedCurrencies[row]
    }
    
    //MARK:-- Upload Functions
    
    func requestWith(url: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        print("inside requestwith")
        //let url = "http://google.com" /* your API url */
        SVProgressHUD.show()
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "fileToUpload", fileName: "fileToUpload1223345.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print(response)
                    if let json = response.data {
                        do{
                            let data = try JSON(data: json)
                            print(data[0])
                            if(data[0] != "File Uploaded"){
                                print("File could not be uploaded")
                            }
                        }
                        catch{
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
                SVProgressHUD.dismiss()
            }
        }
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
