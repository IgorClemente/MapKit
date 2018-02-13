//
//  MapViewController.swift
//  MinhasViagens
//
//  Created by MACBOOK AIR on 12/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mainMap:MKMapView?
    
    var travelInformation:Dictionary<String,String>?
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var locationGeocoder: CLGeocoder       = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let map = self.mainMap else {
            return
        }
        
        if let information = self.travelInformation {
           guard let latitude  = information["latitude"],
                 let longitude = information["longitude"],
                 let latitudeConverted  = Double(latitude),
                 let longitudeConverted = Double(longitude),
                 let address   = information["address"] else {
               return
           }
           
           let latitudeDegrees: CLLocationDegrees  = latitudeConverted
           let longitudeDegrees: CLLocationDegrees = longitudeConverted
            
           let coordinate = CLLocationCoordinate2DMake(latitudeDegrees,longitudeDegrees)
            
           let travelAnnotation = MKPointAnnotation()
           travelAnnotation.coordinate = coordinate
           travelAnnotation.title      = address
           travelAnnotation.subtitle   = address
            
           map.addAnnotation(travelAnnotation)
           map.showAnnotations(map.annotations, animated: true)
           return
        }
        
        self.searchLocation()
        let longGesturePin = UILongPressGestureRecognizer(target: self,
                                                          action: #selector(tapAddPin(gesture:)))
        longGesturePin.minimumPressDuration = 1.0
        mainMap?.addGestureRecognizer(longGesturePin)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func tapAddPin(gesture g: UIGestureRecognizer) -> Void {
        guard let map = self.mainMap else {
            return
        }
        
        if g.state == UIGestureRecognizerState.began {
           let pointPress = g.location(in: map)
           let coordinatePointConverted = map.convert(pointPress, toCoordinateFrom: self.mainMap)
           let locationFinally = CLLocation(latitude: coordinatePointConverted.latitude,
                                            longitude: coordinatePointConverted.longitude)
            
           self.locationGeocoder.reverseGeocodeLocation(locationFinally, completionHandler: { (locations, error) in
               guard let locationsBest = locations,
                     let location      = locationsBest.first,
                     let coordinate    = location.location?.coordinate,
                     let street        = location.thoroughfare,
                     let country       = location.country else {
                   return
               }
            
               let annotationPin        = MKPointAnnotation()
               annotationPin.coordinate = coordinate
               annotationPin.title      = street
               annotationPin.subtitle   = country
               map.addAnnotation(annotationPin)
            
               let newPinInformation:[String:String] = ["address": street,
                                                        "latitude": String(coordinate.latitude),
                                                        "longitude": String(coordinate.longitude)]
               app.persistent(information: newPinInformation, completation: { (save) in
                   print("DEBUG -> ",save ? "SUCESS" : "FAIL")
               })
           })
        }
    }
}


extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func searchLocation() -> Void {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate        = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            case .notDetermined:
                self.requestPermittion()
            case .denied:
                if let urlSettings = URL(string: UIApplicationOpenSettingsURLString) {
                   UIApplication.shared.open(urlSettings, options: [:], completionHandler: nil)
                }
            default:
                break
        }
    }
    
    func requestPermittion() -> Void {
        if CLLocationManager.locationServicesEnabled() {
           locationManager.delegate = self
           locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.searchLocation()
            case .denied:
                let message:String  = "Para o correto funcionamento do aplicativo, é necessário conceder acesso a sua localização"
                let permittionAlert = UIAlertController(title: "Acesso Negado",
                                                        message: message,
                                                        preferredStyle: .alert)
                let openSettingsAction = UIAlertAction(title: "Abrir Configurações", style: .default, handler: { (_) in
                    if let urlSettings = URL(string: UIApplicationOpenSettingsURLString) {
                       UIApplication.shared.open(urlSettings, options: [:], completionHandler: nil)
                    }
                })
            
                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                
                permittionAlert.addAction(openSettingsAction)
                permittionAlert.addAction(cancelAction)
                self.present(permittionAlert, animated: true, completion: nil)
            default:
                break
        }
    }
    
    func prepareMap(For location: CLLocation) -> Void {
        guard let map = self.mainMap else {
            return
        }
        
        let coordinate      = location.coordinate
        let coordinateDelta = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, coordinateDelta)
        map.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationBest = locations.last else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        self.prepareMap(For: locationBest)
    }
}
