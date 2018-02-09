//
//  ViewController.swift
//  MapKitSimpleExample
//
//  Created by MACBOOK AIR on 08/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainMap:MKMapView?
    let locationManager:CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController : MKMapViewDelegate, CLLocationManagerDelegate {
    
    func requestPermittion() -> Void {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func prepareMap() -> Void {
        guard let map = self.mainMap else {
            return
        }
        
        let latitudeDegrees:CLLocationDegrees  = -23.638040
        let longitudeDegrees:CLLocationDegrees = -46.635976
        
        let coordinateLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees)
        let coordinateDelta:MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinateLocation, coordinateDelta)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateLocation
        annotation.title      = "Jabaquara Pin Teste"
        annotation.subtitle   = "Pin de teste"
        map.addAnnotation(annotation)
        
        self.requestPermittion()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last,
              let map          = self.mainMap else {
            return
        }
        
        let coordinateDelta: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion        = MKCoordinateRegionMake(bestLocation.coordinate, coordinateDelta)
        map.setRegion(region, animated: true)
    }
}

