//
//  GraphsItem.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 26/01/2018.
//  Copyright © 2018 Francesco Fuggitti. All rights reserved.
//

import UIKit

class GraphsItem: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var currencyFrom = String()
    var rates = [Double]()
    
    var currencyCode = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]
    
    var currencies = ["Austrialian dollar", "Bulgarian lev", "Brazilian real", "Canadian dollar", "Swiss franc", "Chinese yuan renminbi", "Czech koruna", "Danish krone", "Euro", "Pound sterling", "Hong Kong dollar", "Croatian kuna", "Hungarian forint", "Indonesian rupiah", "Israeli shekel", "Indian rupee", "Japanese yen", "South Korean won", "Mexican peso", "Malaysian ringgit", "Norwegian krone", "New Zealand dollar", "Philippine piso", "Polish zloty", "Romanian leu", "Russian rouble", "Swedish krona", "Singapore dollar", "Thai baht", "Turkish lira", "US dollar", "South African rand"]
    
    var flags = [#imageLiteral(resourceName: "australia"),#imageLiteral(resourceName: "bulgaria"),#imageLiteral(resourceName: "brazil"),#imageLiteral(resourceName: "canada"),#imageLiteral(resourceName: "switzerland"),#imageLiteral(resourceName: "china"),#imageLiteral(resourceName: "czech republic"),#imageLiteral(resourceName: "denmark"),#imageLiteral(resourceName: "europe"),#imageLiteral(resourceName: "united kingdom"),#imageLiteral(resourceName: "hong kong"),#imageLiteral(resourceName: "croatia"),#imageLiteral(resourceName: "hungary"),#imageLiteral(resourceName: "indonesia"),#imageLiteral(resourceName: "israel"),#imageLiteral(resourceName: "india"),#imageLiteral(resourceName: "japan"),#imageLiteral(resourceName: "south korea"),#imageLiteral(resourceName: "mexico"),#imageLiteral(resourceName: "malaysia"),#imageLiteral(resourceName: "norway"),#imageLiteral(resourceName: "new zealand"),#imageLiteral(resourceName: "philippines"),#imageLiteral(resourceName: "republic of poland"),#imageLiteral(resourceName: "romania"),#imageLiteral(resourceName: "russia"),#imageLiteral(resourceName: "sweden"),#imageLiteral(resourceName: "singapore"),#imageLiteral(resourceName: "thailand"),#imageLiteral(resourceName: "turkey"),#imageLiteral(resourceName: "usa"),#imageLiteral(resourceName: "south africa")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getRates(selCurrencyFrom: "EUR")
        
    }
    
    func getRates(selCurrencyFrom: String){
        let url = URL(string: "https://api.fixer.io/latest?base="+selCurrencyFrom)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("HTTP request error")
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!)
                    if let dictResponse = json as? [String:Any] {
                        if let currs = dictResponse["rates"] as? [String:Any]{
                            for curr in 0...self.currencyCode.count-1 {
                                if currs[self.currencyCode[curr]] != nil {
                                    self.rates.append(currs[self.currencyCode[curr]] as! Double)
                                }
                                else{
                                    self.rates.append(1)
                                }
                            }
                        }
                        else{
                            print("Rate not present")
                            self.rates.append(0)
                        }
                        OperationQueue.main.addOperation {
                            self.tableView.reloadData()
                        }
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension GraphsItem: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.flag.image = flags[indexPath.row]
        cell.currencyName.text = currencies[indexPath.row]
        
        if rates[indexPath.row] != 0.0 {
            cell.value.text = String(rates[indexPath.row])
        }
        else{
            cell.value.text = "--"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "graphSegue" , sender: cell)
    }
    
}
