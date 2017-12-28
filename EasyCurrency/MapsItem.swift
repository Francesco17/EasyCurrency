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
        
        if sender.state == .ended {
            let location = sender.location(in: mapView)
//            print("**********tapped********")
//            print(location)
            
            let locationCoord = mapView.convert(location, toCoordinateFrom: mapView)
//            print(locationCoord)
            
            let geoCoder = CLGeocoder()
            let loc = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)
            geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in

                var countryLabel = ""

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
            })
            
        }
        
    }
    
        // Add annotation:
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)

    

}
