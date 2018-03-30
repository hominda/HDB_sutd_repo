//
//  mapViewViewController.swift
//  TestOne
//
//  Created by Hominda Marasinghe on 7/3/18.
//  Copyright © 2018 Hominda Marasinghe. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class mapViewViewController: UIViewController {
  @IBOutlet var mapView: MKMapView!
    var locations: [MKPointAnnotation]!

//    fileprivate var locations = [MKPointAnnotation]()
    
//    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIApplication.shared.applicationState == .active {
            mapView.showAnnotations((self.locations)!, animated: true)
            
        } else {
            print("App is backgrounded. New location is %@" )
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        if UIApplication.shared.applicationState == .active {
            mapView.showAnnotations((self.locations)!, animated: true)
            
        } else {
            print("App is backgrounded. New location is %@" )
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
