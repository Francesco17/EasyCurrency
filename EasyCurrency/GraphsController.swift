//
//  GraphsController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 26/01/2018.
//  Copyright © 2018 Francesco Fuggitti. All rights reserved.
//

import UIKit
import QuartzCore

class GraphsController: UIViewController {
    
    var title_graph = String()
    var label = UILabel()
    var lineChart: LineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var today = Date()
        var dateArray = [String]()
        var dateArray_2 = [String]()
        for _ in 1...16{
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            let formatter = DateFormatter()
            let formatter_2 = DateFormatter()
            formatter.dateFormat = "dd"
            formatter_2.dateFormat = "yyyy-MM-dd"
            let stringDate: String = formatter.string(from: today)
            let strigDate_2: String = formatter_2.string(from: today)
            today = yesterday!
            dateArray.append(stringDate)
            dateArray_2.append(strigDate_2)
        }
        dateArray.remove(at: 0)
        dateArray_2.remove(at: 0)
        
        getRates(selCurrencyTo: title_graph, dateArray: dateArray_2) { (rates) in
            print(rates)
        }
        
        var views: [String: AnyObject] = [:]
        
        label.text = "History conversion from EUR to "+title_graph
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-120-[label]", options: [], metrics: nil, views: views))
        
        // simple arrays
        let data: [CGFloat] = [3, 4, -2, 11, 13, 15,7,7,7,7,7,6,6,6,6]
//        let data2: [CGFloat] = [1, 3, 5, 13, 17, 20]
        
        // simple line with custom x axis labels
//        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 10
        lineChart.y.grid.count = 10
        lineChart.x.labels.values = dateArray
        lineChart.y.labels.visible = true
        lineChart.addLine(data)
//        lineChart.addLine(data2)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart]-|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
    }

    
    func getRates(selCurrencyTo: String, dateArray: [String], completion: @escaping ([Double])->()){
        var rates = [Double]()
        for i in 1...dateArray.count-1{
            let url = URL(string: "https://api.fixer.io/"+dateArray[i]+"?symbols="+selCurrencyTo)
            print(url!)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print("HTTP request error")
                }
                else{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!)
                        if let dictResponse = json as? [String:Any] {
                            if let currs = dictResponse["rates"] as? [String:Any]{
                                if currs[selCurrencyTo] != nil {
                                    rates.append(currs[selCurrencyTo] as! Double)
                                }
                                else{
                                    rates.append(-1)
                                }
                            }
                            else{
                                print("Rate not present")
                                rates.append(-2)
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
    


}
