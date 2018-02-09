//
//  ViewController.swift
//  OndeEstou?
//
//  Created by MACBOOK AIR on 08/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var uiMainMap: MKMapView?
    @IBOutlet weak var uiVelocityIndicator: UILabel?
    @IBOutlet weak var uiLongitudeIndicator: UILabel?
    @IBOutlet weak var uiLatitudeIndicator: UILabel?
    @IBOutlet weak var uiAddressInformation: UILabel?
    
    let locationManager: CLLocationManager = CLLocationManager()
    let geocoderManager: CLGeocoder        = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func alertAcessDenied() -> Void {
        let message: String = "O aplicativo necessita de acesso a sua localização"
        let alertNotificationPermittion = UIAlertController(title: "Acesso negado",
                                                            message: message, preferredStyle: .alert)
        
        let actionNofiticationSettings = UIAlertAction(title: "Abrir configurações",
                                                       style: .default, handler: { (_) in
            if let urlSettings = URL(string: UIApplicationOpenSettingsURLString) {
               UIApplication.shared.open(urlSettings, options: [:], completionHandler: nil)
            }
        })
        
        let actionNotificationCancel = UIAlertAction(title: "Cancelar",
                                                     style: .cancel, handler: nil)
        alertNotificationPermittion.addAction(actionNofiticationSettings)
        alertNotificationPermittion.addAction(actionNotificationCancel)
    
        self.present(alertNotificationPermittion, animated: true, completion: nil)
    }
    
    func searchLocation() -> Void {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways,.authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                if let urlSettings = URL(string: UIApplicationOpenSettingsURLString) {
                   UIApplication.shared.open(urlSettings, options: [:], completionHandler: nil)
                }
            default:
                break
        }
    }
}

extension ViewController {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways,.authorizedWhenInUse:
                self.searchLocation()
            case .denied:
                self.alertAcessDenied()
            default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              let map      = self.uiMainMap,
              let velocityLabel  = self.uiVelocityIndicator,
              let longitudeLabel = self.uiLongitudeIndicator,
              let latitudeLabel  = self.uiLatitudeIndicator,
              let addressLabel   = self.uiAddressInformation else {
            return
        }
        
        let latitudeCoordinate: CLLocationDegrees  = location.coordinate.latitude
        let longitudeCoordinate: CLLocationDegrees = location.coordinate.longitude
        let coordinateLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeCoordinate, longitudeCoordinate)
        
        let coordinateDelta: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion        = MKCoordinateRegionMake(coordinateLocation, coordinateDelta)
        
        map.setRegion(region, animated: true)
        
        velocityLabel.text  = String(location.speed)
        longitudeLabel.text = String(location.coordinate.longitude)
        latitudeLabel.text  = String(location.coordinate.latitude)
        
        geocoderManager.reverseGeocodeLocation(location) { (locationsBest, error) in
            guard error == nil,
                  let bestLocation = locationsBest?.first else {
                return
            }
            
            guard let streetInformation  = bestLocation.thoroughfare,
                  let countryInformation = bestLocation.country,
                  let name               = bestLocation.name else {
                return
            }
            addressLabel.text = "\(name) \n\(countryInformation) \n\(streetInformation)"
        }
    }
}

