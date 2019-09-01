//
//  ScanViewController.swift
//  BinancePay
//
//  Created by Hammad Tariq on 18/05/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftKeychainWrapper
import BinanceChain
import SVProgressHUD

class WalletScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scannedCode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        //dismiss(animated: true)
    }
    
    func found(code: String) {
        SVProgressHUD.show()
        self.scannedCode = code
        
        let saveSuccessful: Bool = KeychainWrapper.standard.set(code, forKey: "walletKey")
        if saveSuccessful {
            
            
            let wallet = Wallet(mnemonic: code, endpoint: .testnet)
            wallet.synchronise() { (error) in
                let walletAddress = wallet.account
                let binance = BinanceChain()
                // Get account metadata for an address
                binance.account(address: walletAddress) { (response) in
                    //print(response.account.publicKey)
                    KeychainWrapper.standard.set(wallet.account, forKey: "walletAddress")
                    if(response.account.accountNumber == 0){
                        SVProgressHUD.dismiss()
                        print("account is invalid")
                        let alertTitle = NSLocalizedString("Error", comment: "")
                        let alertMessage = NSLocalizedString("Could not find Binance Chain account. Please try again with correct mnemonic key!", comment: "")
                        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in self.invalidCode()}))
                        self.present(alert, animated: true)
                    }else{
                        SVProgressHUD.dismiss()
                        KeychainWrapper.standard.set(walletAddress, forKey: "walletAddress")
                        //set the root view controller first
                        let sb : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let vc2 = sb.instantiateViewController(withIdentifier: "MainNavigationController")
                        UIApplication.shared.keyWindow?.rootViewController = vc2
                    }
                }
            }
            
        }else {
            print("error")
            let alertTitle = NSLocalizedString("Error", comment: "")
            let alertMessage = NSLocalizedString("Error in saving the information. Please try again!", comment: "")
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func invalidCode(){
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "walletKey")
        if removeSuccessful {
            let sb:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc1 = sb.instantiateViewController(withIdentifier: "StartViewVCNav")
            self.present(vc1, animated: true, completion: nil)
        }
    }
    

}

