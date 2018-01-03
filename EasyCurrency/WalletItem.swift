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
        
        self.depositTextField.text = "Deposit = 100..to be done"
        self.balanceTextField.text = "Balance = 100..to be done"
        
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
                                let am = Double(tra["amount"] as! String)
                                let cu = String(tra["currency"] as! String)
                                let ra = Double(tra["rate"] as! String)
                                let tr = Transaction(amount: am!, currency: cu, rate: ra!, user: user_id)
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
}
