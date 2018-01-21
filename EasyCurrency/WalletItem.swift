//
//  WalletItem.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 28/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit

var transactions = [Transaction]()

class WalletItem: UIViewController {
    
//    MARK: properties
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var depositTextField: UILabel!
    @IBOutlet weak var balanceTextField: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var user_id = Int()
    var deposit = Double()
    var balance = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        getting stored informations

        if let userName_logged = defaults.string(forKey: "username"){
            self.usernameTextField.text = "Username: "+userName_logged.capitalized
        }
        if let user_id = defaults.string(forKey: "user_id"){
            self.user_id = Int(user_id)!
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.tableView.reloadData()
//        self.computeNewBalance(trans: transactions)
        transactions = []
        get_trans(user_id: self.user_id) {
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                self.computeNewBalance(trans: transactions, completion: { (bal) in
                    DispatchQueue.main.async {
                        self.balanceTextField.text = "Balance = "+String(self.balance)
                    }
                })
//                let alert = UIAlertController(title: "Balance Updated!", message: "", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Ok", style:UIAlertActionStyle.default, handler:nil))
//                self.present(alert, animated: true, completion: nil)
                
                self.get_depbal(id: self.user_id) { (dep, bal) in
                    self.defaults.set(dep, forKey: "deposit")
                    DispatchQueue.main.async {
                        self.depositTextField.text = "Deposit = "+dep
//                        self.balanceTextField.text = "Balance = "+bal
                    }
                }
                
                self.balanceTextField.text = "Balance = "+String(self.balance)
            }
        
        }
        
    }
    
    func computeNewBalance(trans: [Transaction], completion: @escaping (Double)->()){
        
        self.balance = defaults.double(forKey: "deposit")
        
        var buff = String()
        for transaction in trans {
            if buff.isEmpty {
                buff = transaction.currency
            }
            else{
                buff = buff+","+transaction.currency
            }
        }
        
        getRates(selCurrencyFrom: "EUR", selCurrencyTo: buff) { (rates) in

            if trans.count > 0 {
                for i in 0...trans.count-1{
                    let oldAmount = trans[i].amount*trans[i].rate
                    print("oldAmount: "+String(oldAmount))
                    let newAmount = oldAmount/rates[i]
                    print("newAmount: "+String(newAmount))
                    self.balance += newAmount
                }
                print("balance: "+String(self.balance))
                self.updateBalance(bal: self.balance)
                
            }
            completion(self.balance)
        }

    }
    
    func updateBalance(bal: Double){
        //        update deposit
        let url2 = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/update_balance_deposit.php")!
        var request2 = URLRequest(url: url2)
        request2.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request2.httpMethod = "POST"
        let postString2 = "deposit=&balance="+String(bal)+"&user_id="+String(self.user_id)
        request2.httpBody = postString2.data(using: .utf8)
        let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
            guard let dat = data2, error2 == nil else {
//              check for fundamental networking error
                print("error=\(String(describing: error2))")
                return
            }
            if let httpStatus = response2 as? HTTPURLResponse, httpStatus.statusCode != 200 {
                //                check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response2))")
            }
            let responseStr = String(data: dat, encoding: .utf8)
            let responseStr2 = responseStr?.data(using:.utf8)!
            do{
                let json = try JSONSerialization.jsonObject(with: responseStr2!)
                if let dictionary = json as? [String: Any]{
                    if let state = dictionary["state"] as? String{
                        if state == "SUCCESS" {
                            print("balance updated")
                        }
                        else if state == "FAIL" {
                            print("Error occurred")
                        }
                    }
                }
            }
            catch {
                print("Error parsing Json")
            }
        }
        task2.resume()
    }
    
    func get_depbal(id: Int, completion: @escaping (String, String)->()){
        var dep = String()
        var bal = String()
        
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/get_dep_bal.php?user_id="+String(id) )
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print("HTTP request error")
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!)
                    if let dictResponse = json as? [String:Any] {
                        if let state = dictResponse["state"] as? String{
                            if state == "SUCCESS"{                                
                                dep = dictResponse["deposit"] as! String
                                bal = dictResponse["balance"] as! String
                            }
                            else {
                                print("Get deposit/balance failed")
                            }
                        }
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
            completion(dep, bal)
        }
        task.resume()
    }
    
    func get_trans(user_id: Int, completion: @escaping ()->()){
        
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/get_transactions.php?user_id="+String(user_id) )
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print("HTTP request error")
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    if let trans = json!["transactions"] as? [[String:Any]]{
                        for tra in trans{
                            let id = String(tra["id"] as! String)
                            let am = Double(tra["amount"] as! String)
                            let cu = String(tra["currency"] as! String)
                            let ra = Double(tra["rate"] as! String)
                            let tr = Transaction(id: id, amount: am!, currency: cu, rate: ra!, user: user_id)
                            transactions.append(tr)
                        }
                    }
                    else{
                        print("Error")
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
            completion()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTransBtn(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addTrans", sender: self)
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "user_id")
        transactions.removeAll()
        tableView.reloadData()
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension WalletItem: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Transaction "+String(indexPath.row+1)+": "+String(transactions[indexPath.row].amount)+" EUR in "+String(transactions[indexPath.row].currency)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let foreignAmount = transactions[indexPath.row].amount * transactions[indexPath.row].rate;
            let baseCurrency = "EUR"
            
            getRates(selCurrencyFrom: transactions[indexPath.row].currency, selCurrencyTo: baseCurrency, completion: { (rates) in
                let amountBack = foreignAmount*rates[0]
                let oldDeposit = self.defaults.double(forKey: "deposit")
                let newDeposit = oldDeposit + amountBack
                transactions[indexPath.row].updateDep(dep: newDeposit)
                self.defaults.set(newDeposit, forKey: "deposit")
                
                transactions[indexPath.row].removeTrans(trans: transactions[indexPath.row])
                transactions.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    self.depositTextField.text = "Deposit = "+String(newDeposit)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            })

        }
    }
    
    func getRates(selCurrencyFrom: String, selCurrencyTo: String, completion: @escaping ([Double])->()){
        var rates = [Double]()
        let url = URL(string: "https://api.fixer.io/latest?base="+selCurrencyFrom+"&symbols="+selCurrencyTo)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("HTTP request error")
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!)
                    let currArray = selCurrencyTo.split(separator: ",")
                    if let dictResponse = json as? [String:Any] {
                        if let currencies = dictResponse["rates"] as? [String:Any]{
                            if currArray.count > 1{
                                for i in 0...currArray.count-1{
//                                    print(currencies["USD"])
                                    rates.append(currencies[String(currArray[i])] as! Double)
                                }
                            }
                            else{
                                if currencies[selCurrencyTo] != nil {
                                    rates.append((currencies[selCurrencyTo] as? Double)!)
                                }
                                else{
                                    print("Rate not present")
                                    rates.append(1)
                                }
                            }
                        }
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
            completion(rates)
        }
        task.resume()
    }
    
    
}
