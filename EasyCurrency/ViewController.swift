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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        navigationItem.title = "EasyCurrency"
//    }
    
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
//                            let cookie = dictionary["cookie"] as? String
//                            print(cookie!)
                            OperationQueue.main.addOperation {
                                self.performSegue(withIdentifier: "loginSuccess", sender: self)
                            }
                        }
                        else if state == "FAIL" {
                            var error_Message = ""
                            if let cause = dictionary["cause"] as? String{
                                if cause == "wrong user"{
                                    error_Message = "Username is wrong! Try again.."
                                }
                                else {
                                    error_Message = "Password is wrong! Try again.."
                                }
                            }
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "ERROR", message: error_Message, preferredStyle: UIAlertControllerStyle.alert)

                                alertController.addAction(UIAlertAction(title: "Ok", style:UIAlertActionStyle.default, handler:nil))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
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

