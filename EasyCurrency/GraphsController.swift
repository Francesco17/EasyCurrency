//
//  GraphsController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 26/01/2018.
//  Copyright © 2018 Francesco Fuggitti. All rights reserved.
//

import UIKit
import QuartzCore
import Charts

class GraphsController: UIViewController, ChartViewDelegate {
    
    var title_graph = String()
    var label = UILabel()
    var lineChart: LineChart!
    
    let myGroup = DispatchGroup()
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lineChartView.delegate = self
        self.lineChartView.noDataText = "No data provided.."
        self.labelText.text = title_graph
        
//        var views: [String: AnyObject] = [:]
        
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
        
        var int_Date = [Int]()
        for value in dateArray {
            int_Date.append(Int(value)!)
        }
        int_Date.reverse()
        
        var yRates = [Double]()
        for i in 0...dateArray_2.count-1{
            myGroup.enter()
            getRates(selCurrencyTo: title_graph, date: dateArray_2[i], completion: { (rate) in
                yRates.append(Double(rate))
                self.myGroup.leave()
            })
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            print(int_Date)
            print(yRates)
            yRates.reverse()
            print(yRates)
            
            
            self.setChartData(xLabel: int_Date, yLabel: yRates)

            
//            self.lineChart = LineChart()
//            self.lineChart.animation.enabled = true
//            self.lineChart.area = false
//            self.lineChart.x.labels.visible = true
//            self.lineChart.x.grid.count = 15
//            self.lineChart.y.grid.count = 3
//            self.lineChart.x.labels.values = dateArray
//            self.lineChart.y.labels.visible = true
//            self.lineChart.addLine(yRates)
//
//            self.lineChart.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(self.lineChart)
//            views["chart"] = self.lineChart
//            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
//            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart]-|", options: [], metrics: nil, views: views))
            
        }
        
//        label.text = "History conversion from EUR to "+title_graph
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = NSTextAlignment.center
//        self.view.addSubview(label)
//        views["label"] = label
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-120-[label]", options: [], metrics: nil, views: views))
        

    }
    
    func setChartData(xLabel: [Int], yLabel: [Double]){
        
        let values = (0..<15).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: Double(xLabel[i]), y: yLabel[i])
        }

//        let values = (0..<15).map { (i) -> ChartDataEntry in
//            let val = Double(arc4random_uniform(UInt32(15)) + 3)
//            return ChartDataEntry(x: Double(i), y: val)
//        }

        let set1 = LineChartDataSet(values: values, label: "DataSet")
        let data = LineChartData(dataSet: set1)

        self.lineChartView.data = data

    }
    
    
    func getRates(selCurrencyTo: String, date: String, completion: @escaping (CGFloat)->()){
        
        var rate = CGFloat()
        let url = URL(string: "https://api.fixer.io/"+date+"?symbols="+selCurrencyTo)
        print(url!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("HTTP request error")
            }
            else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!)
                    if let dictResponse = json as? [String:Any] {
                        print(dictResponse)
                        if let currs = dictResponse["rates"] as? [String:Any]{
                            if currs[selCurrencyTo] != nil {
                                rate = currs[selCurrencyTo] as! CGFloat
                            }
                            else{
                                rate = -1
                            }
                        }
                        else{
                            print("Rate not present")
                            rate = -2
                        }
                    }
                }catch {
                    print("Error parsing Json")
                }
            }
            completion(rate)
        }
        task.resume()
    }


}
