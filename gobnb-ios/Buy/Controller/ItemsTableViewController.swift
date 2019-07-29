//
//  ItemsTableViewController.swift
//
//
//  Created by Hammad Tariq on 18/05/2019.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ItemTableViewCell: UITableViewCell{
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
}

class ItemsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shoppingCartView: ShoppingCartView!
    
    var peopleAddress:String = ""
    var itemsArray = [[String]]()
    var itemArrayToPass = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.separatorStyle = .none
        tableView.rowHeight = 200
        //add shopping cart subview
        shoppingCartView.frame = CGRect(x: 0,
                                     y: self.view.bounds.size.height - shoppingCartView.bounds.size.height,
                                     width: self.view.bounds.size.width,
                                     height: shoppingCartView.bounds.size.height)
        
        let addressToQuery = "http://zerobillion.com/binancepay/getItems.php?address=\(peopleAddress)"
        fetchItems(url: addressToQuery)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.view.addSubview(shoppingCartView)
        //View cart subview at the bottom funcationality
        if ShoppingCartModel.shoppingCartArray.isEmpty {
            shoppingCartView.isHidden = true
        }else{
            let totalPriceInCart = UserDefaults.standard.double(forKey: "totalPriceInCart")
            let totalItemsInCart = UserDefaults.standard.integer(forKey: "totalItemsInCart")
            shoppingCartView.totalPrice.text = "\(totalPriceInCart) BNB"
            shoppingCartView.totalQty.text = "\(totalItemsInCart)"
            shoppingCartView.viewCartButton.addTarget(self, action: Selector(("cartButtonTapped:")), for: .touchUpInside)
            shoppingCartView.isHidden = false
        }
    }
    
    @objc func cartButtonTapped(_ sender: UIButton){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingCartVC") as? UIViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func fetchItems(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    
                    for result in resultJSON{
                        var indiResult = [String]()
                        //print(result.1["item_name"])
                        indiResult.append(result.1["item_name"].string ?? "");
                        indiResult.append(result.1["item_description"].string ?? "");
                        indiResult.append(result.1["item_image"].string ?? "");
                        indiResult.append(result.1["price"].string ?? "");
                        self.itemsArray.append(indiResult);
                    }
                    print(self.itemsArray)
                    self.tableView.reloadData()
                }
        }
    }
    
    func itemTapped(){
        print("hello")
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCellItems", for: indexPath) as! ItemTableViewCell
        
        var items = itemsArray[indexPath.item]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.itemTitle.text = items[0]
        cell.itemDescription.text = NSLocalizedString("\(items[1])", comment: "")
        cell.itemPrice.text = "\(items[3])"
        cell.itemTitle.sizeToFit()
        cell.itemDescription.sizeToFit()
        //cell.itemPrice.sizeToFit()
        cell.backgroundColor = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        Alamofire.request(items[2]).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.itemImage.image = image
                //cell.thumbnailImage.image = image
            } else {
                print("Data is nil. I don't know what to do :(")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(itemsArray[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemsArray[indexPath.item])
        itemArrayToPass = itemsArray[indexPath.item]
        itemArrayToPass.append(peopleAddress)
        performSegue(withIdentifier: "goToPayment", sender: self)
        
        //navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ItemDetailViewController
        {
            let vc = segue.destination as? ItemDetailViewController
            vc?.itemArray = itemArrayToPass
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //remove subview from navigation controller otherwise it will persist into next viewcontroller
        shoppingCartView.removeFromSuperview()
    }
    
    
}

