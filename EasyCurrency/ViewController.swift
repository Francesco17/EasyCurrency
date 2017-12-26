//
//  ViewController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 24/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    //    MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var passwTextfield: UITextField!
    @IBOutlet weak var passLabel: UILabel!
    
    
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
        
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/verify_user.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "name="+nameTextField.text!+"&password="+passwTextfield.text!
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
//                check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
        
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let responseString2 = responseString?.data(using:.utf8)!
//            print("responseString = \(String(describing: responseString))")
            do{
                let json = try JSONSerialization.jsonObject(with: responseString2!)
                if let dictionary = json as? [String: Any]{
                    if let state = dictionary["state"] as? String{
                        if state == "SUCCESS" {
                            let cookie = dictionary["cookie"] as? String
                            print(cookie!)
                        }
                    }
                }
                
            }
            catch {
                print("Error parsing Json")
            }
           
        }
        task.resume()
        
    }
    
    
}

