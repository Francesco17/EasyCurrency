//
//  RegistrationViewController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 27/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit
import Foundation

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var userTextfield: UITextField!
    
    @IBOutlet weak var pass1Textfield: UITextField!
    
    @IBOutlet weak var pass2Textfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitReg_btn(_ sender: UIButton) {
        if userTextfield.text != "" || pass1Textfield.text != ""{
            if pass1Textfield.text == pass2Textfield.text{
                
                let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/add_user.php")!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let postString = "name="+userTextfield.text!+"&password="+pass1Textfield.text!
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
                                    OperationQueue.main.addOperation {
                                        self.performSegue(withIdentifier: "regSuccess", sender: self)
                                    }
                                }
                                else if state == "FAIL" {
                                    var error_Message = ""
                                    if let cause = dictionary["cause"] as? String{
                                        error_Message = cause
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
            else{
                
                let error_Message = "Two passwords do not match!"
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "ERROR", message: error_Message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style:UIAlertActionStyle.default, handler:nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else {
            let error_Message = "Some field is empty. Please fill in!"
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "ERROR", message: error_Message, preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style:UIAlertActionStyle.default, handler:nil))
                
                self.present(alertController, animated: true, completion: nil)
        }
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
