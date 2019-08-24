//
//  FAQViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 24/08/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import FAQView

class FAQsViewController: UIViewController {
    
    @IBOutlet weak var viewForFAQs: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createFAQs()
    }
    
    
    
    func createFAQs(){
        let items = [FAQItem(question: NSLocalizedString("What is gobnb for iOS?", comment: ""), answer: NSLocalizedString("gobnb is a 'pay at the restaurant table' app that makes it easier for you to find right items from the restaurant menu and pay in your favourite Binance DEX backed tokens.", comment: "")),
                     FAQItem(question: NSLocalizedString("Does this app support stablecoins?", comment: ""), answer: NSLocalizedString("Yes, we are currently supporting Stably-backed USDSB stablecoin and we will add more in the future as well!", comment: "")),
                     FAQItem(question: NSLocalizedString("Can gobnb be seen as a wallet?", comment: ""), answer: NSLocalizedString("gobnb is using Binance DEX wallet natively, that means it does not generate any of it's own wallet accounts and just communicate with your Binance DEX wallet to send and receive tokens to and from other's accounts.", comment: "")),
                     FAQItem(question: NSLocalizedString("Can I add my own products to gobnb?", comment: ""), answer: NSLocalizedString("Yes sure! Just go into 'Make money selling' section from the menu and list your own products, next thing you know you are appearing on the app and anybody can buy from you!", comment: "")),
                     FAQItem(question: NSLocalizedString("Is gobnb safe?", comment: ""), answer: NSLocalizedString("gobnb follows industry standard encryption modules to keep your data safe. All of our source-code is open to review and we we also ask experts regularly for security audits. We do not store any of your wallet information anywhere other than your own device (in an industry standard secure enclave), while we only communicate order specific data to our server.", comment: "")),
                     FAQItem(question: NSLocalizedString("Do you track users?", comment: ""), answer: NSLocalizedString("Not at all! We are highly decentralized adn pro-privacy minded, the app does not contain any tracking code, even not for usage analytics. We will get how many orders were placed and how many were successful eventually from the database, that is all we are interested in, not your personal information or how you interact with the app.", comment: "")),
                     FAQItem(question: NSLocalizedString("Can I sell anything on this app? Like even the items law enforcement would not like?", comment: ""), answer: NSLocalizedString("No! We monitor actively what is being uploaded on the app and we reserve the rights to remove any objectionable item or content. However, we do not like to perform this police duty. In the future, we will like to make the vetting process decentralized under a DAO and let community vet items itself (against a compensation from the DAO, ofcourse!", comment: ""))]
        
        let faqView = FAQView(frame: view.frame, items: items)
        // Set up data detectors for automatic detection of links, phone numbers, etc., contained within the answer text.
        faqView.dataDetectorTypes = [.phoneNumber, .calendarEvent, .link]
        // Question text color
        faqView.questionTextColor = .black
        // View background color
        faqView.viewBackgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // Question text font
        faqView.questionTextFont = UIFont.systemFont(ofSize: 17.0)
        faqView.answerTextFont = UIFont.systemFont(ofSize: 14.0)
        faqView.titleLabelTextFont = UIFont.systemFont(ofSize: 19.0)
        viewForFAQs.addSubview(faqView)
        
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
