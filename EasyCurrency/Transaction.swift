//
//  Transactions.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 02/01/2018.
//  Copyright © 2018 Francesco Fuggitti. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard

class Transaction {
    
    var id: String
    var amount: Double
    var currency: String
    var rate: Double
    var user: Int
    
    init(id: String, amount: Double, currency: String, rate: Double, user: Int) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.rate = rate
        self.user = user
    }
    
    func saveTrans(diffDepAmount: Double) {
//        save transaction
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/add_transaction.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "amount="+String(self.amount)+"&currency="+self.currency+"&rate="+String(self.rate)+"&user_id="+String(self.user)
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
            do{
                let json = try JSONSerialization.jsonObject(with: responseString2!)
                if let dictionary = json as? [String: Any]{
                    if let state = dictionary["state"] as? String{
                        if state == "SUCCESS" {
                            self.id = dictionary["id"] as! String
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
        task.resume()
        
        updateDep(dep: diffDepAmount)
    
    }
    
    func updateDep (dep: Double){
        //        update deposit
        let url2 = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/update_balance_deposit.php")!
        var request2 = URLRequest(url: url2)
        request2.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request2.httpMethod = "POST"
        let postString2 = "deposit="+String(dep)+"&balance=&user_id="+String(self.user)
        request2.httpBody = postString2.data(using: .utf8)
        let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
            guard let dat = data2, error2 == nil else {
//                check for fundamental networking error
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
                            print("deposit updated")
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
    
    func removeTrans(trans: Transaction){
        
        let url = URL(string: "http://francesco1735212.ddns.net:3000/server_app_mob/delete_transaction.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "id="+trans.id
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
            do{
                let json = try JSONSerialization.jsonObject(with: responseString2!)
                if let dictionary = json as? [String: Any]{
                    if let state = dictionary["state"] as? String{
                        if state == "SUCCESS" {
                            print("transaction deleted")
                        }
                        else if state == "FAIL" {
                            let cause = dictionary["cause"] as? String
                            print("cause: "+cause!)
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
