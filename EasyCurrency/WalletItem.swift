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
        
        get_depbal(id: self.user_id) { (dep, bal) in
            self.defaults.set(dep, forKey: "deposit")
            DispatchQueue.main.async {
                self.depositTextField.text = "Deposit = "+dep
                self.balanceTextField.text = "Balance = "+bal
            }
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
        
        get_trans(user_id: self.user_id) {
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
            transactions[indexPath.row].removeTrans(trans: transactions[indexPath.row])
//            transactions[indexPath.row].removeTrans(id: transactions[indexPath.row].id)
            transactions.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    
    
    
}
