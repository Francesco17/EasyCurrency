//
//  WalletItem.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 28/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit

class WalletItem: UIViewController {
    
//    MARK: properties
    
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var depositTextField: UILabel!
    @IBOutlet weak var balanceTextField: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        getting stored informations
        let defaults = UserDefaults.standard
        if let userName_logged = defaults.string(forKey: "username"){
            self.usernameTextField.text = "Username: "+userName_logged.capitalized
        }
        self.depositTextField.text = "Deposit = 100..to be done"
        self.balanceTextField.text = "Balance = 100..to be done"
        
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTransBtn(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func logoutBtn(_ sender: UIBarButtonItem) {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
