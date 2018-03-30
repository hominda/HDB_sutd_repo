//
//  ViewController.swift
//  TestOne
//
//  Created by Hominda Marasinghe on 5/3/18.
//  Copyright © 2018 Hominda Marasinghe. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    let screenSize = UIScreen.main.bounds
    
    @IBOutlet weak var timeLineLable: UILabel!
    @IBOutlet weak var progressBar: UIView!
    var locations = [MKPointAnnotation]()
    
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self as! CLLocationManagerDelegate
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print(screenWidth)
        print(screenHeight)

        // Enable background location updates
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        // Start location updates
        updateLabelFrame()
        self.locationManager.startUpdatingLocation()
  
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func updateLocation(_ sender: Any) {
        print("Location Update  ------------------------- On ▶️")
        self.locationManager.startUpdatingLocation()
        perform(#selector(stopUpdatingLocation), with: nil, afterDelay: 5)
    }
    
    func stopUpdatingLocation() {
       self.locationManager.stopUpdatingLocation()
        print("Location Update ---------------------------- OFF ⏸")

    }
    
    
    func updateLabelFrame() {
        let maxSize = CGSize(width: 700, height: 300)
//        let size = timeLineLable.sizeThatFits(maxSize)
//        timeLineLable.frame = CGRect(origin: CGPoint(x: 10, y: 100), size: size)
    }
    
    @IBAction func callMap(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewViewController") as! mapViewViewController
        secondViewController.locations = self.locations
        self.navigationController?.pushViewController(secondViewController, animated: true)
       
    }
    

}
// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation
        annotation.coordinate = mostRecentLocation.coordinate
        // Also add to our map so we can remove old values later
        self.locations.append(annotation)
        // Remove values if the array is too big
        while locations.count > 100 {
            let annotationToRemove = self.locations.first!
            self.locations.remove(at: 0)
            // Also remove from the map
            // mapView.removeAnnotation(annotationToRemove)
        }
        if UIApplication.shared.applicationState == .active {
            //                mapView.showAnnotations(self.locations, animated: true)
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
    
}


