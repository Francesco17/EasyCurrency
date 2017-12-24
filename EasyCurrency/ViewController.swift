//
//  ViewController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 24/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //    MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK: Actions
    
    @IBAction func SubmitBtn(_ sender: UIButton) {
        print("utente inserito: "+nameTextField.text!)
        
//        inserire codice per validare login
    }
    
    
}

