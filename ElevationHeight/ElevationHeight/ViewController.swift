//
//  ViewController.swift
//  ElevationHeight
//
//  Created by Amit on 28/11/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblHeight: UILabel!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

//         Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy
        locationManager.requestWhenInUseAuthorization() // Request permission
        locationManager.startUpdatingLocation() // Start fetching location
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let altitude = location.altitude // Altitude in meters
        print("Current Elevation: \(altitude) meters")
        
        self.lblHeight.text = "current height: \(altitude) meters"
        // Stop updating location to conserve battery
//        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error.localizedDescription)")
    }
}

