//
//  ViewController.swift
//  Loco
//
//  Created by Smart on 2019/07/20.
//  Copyright © 2019 Smart. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 35.665751, longitude: 139.728687, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        view = mapView
        
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125)
//        marker.title = "東京駅"
//        marker.snippet = "こちら"
//        marker.map = mapView
        
    
    }
    
    func getPlaces(coordinate: CLLocationCoordinate2D) {
       
        let requestURLString = "https://map.yahooapis.jp/search/local/V1/localSearch?cid=d8a23e9e64a4c817227ab09858bc1330&dist=2&query=%E3%82%B3%E3%83%B3%E3%83%93%E3%83%8B&appid=dj00aiZpPURMZ1RFbm94cDVJbyZzPWNvbnN1bWVyc2VjcmV0Jng9NmY-&output=json&sort=geo"
            + "&lat=" + String(coordinate.latitude) + "&lon=" + String(coordinate.longitude)
        Alamofire.request(requestURLString).responseJSON { response in
            //            print("Request: \(String(describing: response.request))")   // original url request
            //            print("Response: \(String(describing: response.response))") // http url response
            //            print("Result: \(response.result)")                         // response serialization result
            //
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                let features = json["Feature"]
                
                for ( _ ,subJson):(String, JSON) in features {
                    
                    //                    print(subJson["Name"].stringValue)
                    //                    print(subJson["Property"]["Address"].stringValue)
                    //                    print(subJson["Geometry"]["Coordinates"].stringValue.split(separator: ","))
                    
                    let coordinate = subJson["Geometry"]["Coordinates"].stringValue.split(separator: ",")
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude:Double(coordinate[1])!,
                                                             longitude:Double(coordinate[0])!)
                    marker.title = subJson["Name"].stringValue
                    marker.snippet = subJson["Property"]["Address"].stringValue
                    marker.map = self.mapView
                }
                
                //                print("JSON: \(json)") // serialized json response
            }
            
        }
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print(marker)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            // Show dialog to ask user to allow getting location data
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            print("latitude: \(latitude)\nlongitude: \(longitude)")
        
            let yourlocation = GMSCameraPosition.camera(withLatitude: latitude,
                                                        longitude: longitude,
                                                        zoom: 15)
            mapView.camera = yourlocation
            
            getPlaces(coordinate: location.coordinate)
        }
        
    }
       
    
}

