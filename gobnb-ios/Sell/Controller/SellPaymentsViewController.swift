//
//  SellPaymentsViewController.swift
//  gobnb-ios
//
//  Created by Hammad Tariq on 11/08/2019.
//  Copyright © 2019 Hammad Tariq. All rights reserved.
//

import UIKit
import Charts

class SellPaymentsViewController: UIViewController {

    @IBOutlet weak var pieChart: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartUpdate()
       
    }
    
    func pieChartUpdate () {
        let entry1 = PieChartDataEntry(value: Double(10), label: "BNB")
        let entry2 = PieChartDataEntry(value: Double(24), label: "USDSC")
        let entry3 = PieChartDataEntry(value: Double(38), label: "USDT")
        let dataSet = PieChartDataSet(entries: [entry1, entry2, entry3], label: "Payment Domination")
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.chartDescription?.text = "Share of Widgets by Type"
        
        //All other additions to this function will go here
        
        //This must stay at end of function
        pieChart.notifyDataSetChanged()
    }
   

}
