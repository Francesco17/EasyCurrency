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
    var selCurrencyFrom = ""
    var selCurrencyTo = ""
    
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
        
        selCurrencyFrom = currencyData[currencyFrom.selectedRow(inComponent: 0)]
        selCurrencyTo = currencyData[currencyTo.selectedRow(inComponent: 0)]
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func changeBtn(_ sender: UIButton) {
        
        var rate = Double(1)
        
        func getRates(selCurrencyFrom: String, selCurrencyTo: String, completion: @escaping (Double)->()){
//            print("FROM: "+selCurrencyFrom)
//            print("TO: "+selCurrencyTo)
            
            let url = URL(string: "https://api.fixer.io/latest?base="+selCurrencyFrom+"&symbols="+selCurrencyTo)
//            print(url!)
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if error != nil {
                    print("HTTP request error")
                }
                else{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!)
                        if let dictResponse = json as? [String:Any] {
                            
                            if let currencies = dictResponse["rates"] as? [String:Any]{
                                
                                if currencies[self.selCurrencyTo] != nil {
                                    rate = (currencies[self.selCurrencyTo] as? Double)!
//                                    print(rate)
                                    
                                }
                                else{
                                    print("Rate not present")
                                }
                            }
                        }
                    }catch {
                        print("Error parsing Json")
                    }
                }
                completion(rate)
            }
            task.resume()
        }
        
        getRates(selCurrencyFrom: selCurrencyFrom, selCurrencyTo: selCurrencyTo){ rate in
            
            DispatchQueue.main.async {
                let result =  Double(self.valueFrom.text!)!*rate
                self.valueTo.text = String(result)
            }
        }
        
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
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
//            print("currency from = "+selCurrencyFrom)
        }
        else{
            selCurrencyTo = currencyData[row]
//            print("currency to = "+selCurrencyTo)
        }
        
    }

}
