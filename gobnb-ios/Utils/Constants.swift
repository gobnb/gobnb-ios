//
//  Constants.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 28/06/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import Foundation
//let date = NSDate()
//let timestamp = UInt64(floor(date.timeIntervalSince1970))
//let numberAsString = String(timestamp)
//let subString = numberAsString.dropLast(2)
//let trimmedNumber = Int(subString) ?? 0
struct Constants {
    /*Original http://zerobillion.com/binancepay/index.php*/
    static let backendServerURL: [UInt8] = [41, 4, 4, 52, 95, 67, 74, 29, 4, 6, 10, 44, 58, 35, 14, 3, 10, 13, 90, 34, 31, 29, 107, 7, 5, 11, 6, 15, 23, 0, 62, 50, 54, 77, 3, 11, 7, 17, 57, 94, 0, 44, 21]
    
    static let backendServerURLBase : String = "http://zerobillion.com/binancepay/"
    static let imageBaseFolder = "/images/storeImages/"
    static let itemsImageBaseFolder = "/images/itemImages/"
    
    static let testnetURL = "https://testnet-explorer.binance.org/tx/"
    
    static let basicUUID = "Benson & Hedges takes you to the darkest corner of the world"
}

