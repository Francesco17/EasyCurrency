//
//  Transactions.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 02/01/2018.
//  Copyright © 2018 Francesco Fuggitti. All rights reserved.
//

import Foundation

class Transaction {
    
    var amount: Double
    var currency: String
    var rate: Double
    var user: String
    var id: String
    
    init(amount: Double, currency: String, rate: Double, user: String) {
        self.amount = amount
        self.currency = currency
        self.rate = rate
        self.user = user
        self.id = ""
    }
    
    func saveTrans() {
        
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/add_transaction.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "amount="+String(self.amount)+"&currency="+self.currency+"&rate="+String(self.rate)+"&user_id="+self.user
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("HTTP request error")
            }
            else{
                let responseString = String(data: data!, encoding: .utf8)
                let responseString2 = responseString?.data(using:.utf8)!
                do{
                    let json = try JSONSerialization.jsonObject(with: responseString2!)
                    if let dictResponse = json as? [String:Any] {
                        if let state = dictResponse["state"] as? String{
                            if state == "SUCCESS" {
                                self.id = dictResponse["id"] as! String
                                print("Transazione salvata")
                            }
                            else{
                                print("Error occurred")
                            }
                        }
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
        }
        task.resume()
    }
    
}
