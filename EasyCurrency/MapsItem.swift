//
//  SecondViewController.swift
//  EasyCurrency
//
//  Created by Francesco Fuggitti on 26/12/2017.
//  Copyright © 2017 Francesco Fuggitti. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapsItem: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        var countryLabel = ""
        
        if sender.state == .ended {
            let location = sender.location(in: mapView)
            
            let locationCoord = mapView.convert(location, toCoordinateFrom: mapView)

            let geoCoder = CLGeocoder()
            let loc = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)
            geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in

                if (error != nil) {
                    print("Unable to Reverse Geocode Location (\(String(describing: error)))")
                    countryLabel = "Unable to Find Address for Location"
                    
                } else {
                    if (placemarks != nil), let placemark = placemarks?.first {
                        if placemark.country != nil {
                            countryLabel = placemark.isoCountryCode!
                        }
                        else{
                            countryLabel = "SEA"
                        }
                    } else {
                        countryLabel = "No Matching Addresses Found"
                    }
                }
                
//                print(countryLabel)
                var countryCurrency = ""
                
                func countryRequest(countryLabel: String, completion: @escaping (String)->()){
                    let url = URL(string: "https://restcountries.eu/rest/v2/alpha/"+countryLabel)!
//                    print(url)
                    
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        
                        if error != nil {
                            print("HTTP request error")
                        }
                        else{
                            do{
                                let json = try JSONSerialization.jsonObject(with: data!)
                                if let dictResponse = json as? [String:Any] {
                                    
                                    if let currencies = dictResponse["currencies"] as? [[String:Any]]{
                                        
                                        if currencies.first!["name"] != nil{
                                            countryCurrency = currencies.first!["name"]! as! String
//                                            print(countryCurrency)
                                            
                                        }
                                        else{
                                            print("Currency not present")
                                        }
                                    }
                                }
                            }catch {
                                print("Error parsing Json")
                                countryCurrency = countryLabel
                            }
                            
                        }
                        completion(countryCurrency)
                    }
                    task.resume()
                    
                }
                
                countryRequest(countryLabel: countryLabel){ countryCurrency in

                    DispatchQueue.main.async {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        let locat:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationCoord.latitude, locationCoord.longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = locat
                        annotation.title = countryCurrency
//                        print("titolo immesso: "+countryCurrency)
                        //                annotation.subtitle = ""
                        self.mapView.addAnnotation(annotation)
                    }
                    
                }

                
            })

        }
        
    }
    
    @IBAction func logoutAct(_ sender: Any) {
        
        OperationQueue.main.addOperation {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    

}
