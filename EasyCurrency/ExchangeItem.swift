//
//  ExchangeItem.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 28/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit

class ExchangeItem: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currencies = ["Austrialian dollar", "Bulgarian lev", "Brazilian real", "Canadian dollar", "Swiss franc", "Chinese yuan renminbi", "Czech koruna", "Danish krone", "Euro", "Pound sterling", "Hong Kong dollar", "Croatian kuna", "Hungarian forint", "Indonesian rupiah", "Israeli shekel", "Indian rupee", "Japanese yen", "South Korean won", "Mexican peso", "Malaysian ringgit", "Norwegian krone", "New Zealand dollar", "Philippine piso", "Polish zloty", "Romanian leu", "Russian rouble", "Swedish krona", "Singapore dollar", "Thai baht", "Turkish lira", "US dollar", "South African rand"]
    
    var flags = [#imageLiteral(resourceName: "australia"),#imageLiteral(resourceName: "bulgaria"),#imageLiteral(resourceName: "brazil"),#imageLiteral(resourceName: "canada"),#imageLiteral(resourceName: "switzerland"),#imageLiteral(resourceName: "china"),#imageLiteral(resourceName: "czech republic"),#imageLiteral(resourceName: "denmark"),#imageLiteral(resourceName: "europe"),#imageLiteral(resourceName: "united kingdom"),#imageLiteral(resourceName: "hong kong"),#imageLiteral(resourceName: "croatia"),#imageLiteral(resourceName: "hungary"),#imageLiteral(resourceName: "indonesia"),#imageLiteral(resourceName: "israel"),#imageLiteral(resourceName: "india"),#imageLiteral(resourceName: "japan"),#imageLiteral(resourceName: "south korea"),#imageLiteral(resourceName: "mexico"),#imageLiteral(resourceName: "malaysia"),#imageLiteral(resourceName: "norway"),#imageLiteral(resourceName: "new zealand"),#imageLiteral(resourceName: "philippines"),#imageLiteral(resourceName: "republic of poland"),#imageLiteral(resourceName: "romania"),#imageLiteral(resourceName: "russia"),#imageLiteral(resourceName: "sweden"),#imageLiteral(resourceName: "singapore"),#imageLiteral(resourceName: "thailand"),#imageLiteral(resourceName: "turkey"),#imageLiteral(resourceName: "usa"),#imageLiteral(resourceName: "south africa")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
//        var currencyData = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]

        
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension ExchangeItem: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.flag.image = flags[indexPath.row]
        cell.currencyName.text = currencies[indexPath.row]
        cell.value.text = "--"
        
        return cell
    }
}
