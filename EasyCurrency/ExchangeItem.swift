//
//  ExchangeItem.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 28/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit

class ExchangeItem: UIViewController {
    
    @IBOutlet weak var currencyFrom: UIPickerView!
    @IBOutlet weak var valueFrom: UITextField!
    
    @IBOutlet weak var currencyTo: UIPickerView!
    @IBOutlet weak var valueTo: UITextField!
    
    var currencyData: [String] = [String]()
    var selCurrencyFrom: String?
    var selCurrencyTo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.currencyFrom.delegate = self
        self.currencyFrom.dataSource = self
        
        self.currencyTo.delegate = self
        self.currencyTo.dataSource = self
        
        currencyData = ["AUD", "BNG", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]
        
        currencyFrom.selectRow(8, inComponent: 0, animated: true)
        currencyTo.selectRow(30, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}

extension ExchangeItem: UIPickerViewDelegate, UIPickerViewDataSource{

    //    number of columns for each picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return currencyData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyData[row]
    }
    
    //    detecting selected currency
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == currencyFrom{
            selCurrencyFrom = currencyData[row]
            print("currency from = "+selCurrencyFrom!)
        }
        else{
            selCurrencyTo = currencyData[row]
            print("currency to = "+selCurrencyTo!)
        }
        
    }

}
