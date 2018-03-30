//  mainViewController.swift
//  TestOne
//
//  Created by Hominda Marasinghe on 13/3/18.
//  Copyright © 2018 Hominda Marasinghe. All rights reserved.
import UIKit
import CoreLocation
import MapKit
import CoreData

class mainViewController: UIViewController {

    var updateTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var locations = [MKPointAnnotation]()
     var LocationData: [NSManagedObject] = []
    var mostRecentLocation : CLLocation?
    var mostRecentSpeed : CLLocationSpeed?
    var mostRecentAltitude : CLLocationDistance?
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reinstateBackgroundTasks
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // Enable background location updates
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        // Start location updates
        self.determineMyCurrentLocation()
        
        self.mostRecentLocation = CLLocation() ; self.mostRecentSpeed = CLLocationSpeed() ; self.mostRecentAltitude = CLLocationDistance()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reinstateBackgroundTask() {
        if updateTimer != nil && (backgroundTask == UIBackgroundTaskInvalid) {
            registerBackgroundTask()
        }
    }
    
    @IBAction func didTapPlayPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            updateTimer = Timer.scheduledTimer(timeInterval: 20, target: self,
                                               selector: #selector(makeWave5min), userInfo: nil, repeats: true)
            registerBackgroundTask()
        } else {
            updateTimer?.invalidate()
            updateTimer = nil
            if backgroundTask != UIBackgroundTaskInvalid {
                endBackgroundTask()
            }
        }
    }
    @IBAction func showRecords(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecodesViewController") as! RecodesViewController
//        secondViewController.locations = self.locations
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func makeWave5min(){
        switch UIApplication.shared.applicationState {
        case .active:
            self.updateLocation()
            let date = Date()
//            let calendar = Calendar.current
//            let hour = calendar.component(.hour, from: date)
//            let minutes = calendar.component(.minute, from: date)
            
            self.saveToLocalDB(datetime: date, latitude: (self.mostRecentLocation?.coordinate.latitude)!, longitude:(self.mostRecentLocation?.coordinate.longitude)!)
            print("App is NOT backgrounded(active) ⤴️.  = \(self.backgroundTask)")

        case .background:
            self.updateLocation()
            let date = Date()
            //            let calendar = Calendar.current
            //            let hour = calendar.component(.hour, from: date)
            //            let minutes = calendar.component(.minute, from: date)
            self.saveToLocalDB(datetime: date, latitude: (self.mostRecentLocation?.coordinate.latitude)!, longitude:(self.mostRecentLocation?.coordinate.longitude)!)
            
            print("App is backgrounded. = \(self.backgroundTask)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        case .inactive:
            
            print("App is inactive. = \(self.backgroundTask)")
            break
        }
    }
// MARK: LocalDB

    func saveToLocalDB(datetime: Date , latitude: Double ,longitude:Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let LocationDataEntity = NSEntityDescription.entity(forEntityName: "LocationData",
                                                in: managedContext)!
        let Data = NSManagedObject(entity: LocationDataEntity,
                                     insertInto: managedContext)
        Data.setValue(datetime, forKeyPath: "datetime")
        Data.setValue(latitude, forKeyPath: "latitude")
        Data.setValue(longitude, forKeyPath: "longitude")
        Data.setValue(0, forKeyPath: "updateStatus")
        
        
        do {
            //
            self.UpdateLocationArray()
            try managedContext.save()

            LocationData.append(Data)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
// MARK: Locatoin
    func updateLocation() {
        print("Location Update  ------------------------- On ▶️")
        self.locationManager.startUpdatingLocation()
        perform(#selector(stopUpdatingLocation), with: nil, afterDelay:1)
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
        print("Location Update ---------------------------- OFF ⏸")
        
    }
    func UpdateLocationArray() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = (self.mostRecentLocation?.coordinate)!
        // Also add to our map so we can remove old values later
        self.locations.append(annotation)
        
        while locations.count > 100 {
            let annotationToRemove = self.locations.first!
            self.locations.remove(at: 0)
            // Also remove from the map
            // mapView.removeAnnotation(annotationToRemove)
        }
    }
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
            self.mostRecentLocation = locationManager.location
            locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func callMap(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewViewController") as! mapViewViewController
        secondViewController.locations = self.locations
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    
    func submit2(){
        var request = URLRequest(url: URL(string:  "http://103.24.77.43/mongoapi/insert_activity_data.php")!)
        request.httpMethod = "POST"
        let ss = "[{\"deviceId\": \"9db265b11f89568d8c0c14c7HOMIeN001\", \"lat\": \"23.000\",\"lng\": \"23.0000\", \"time\": \"HelloWorld\", \"speed\": \"HelloWorld\", \"alt\": \"HelloWorld\", \"accu\": \"HelloWorld\", \"wifiAP\": \"HelloWorld\"}]"
        let postString =  String(format: "data=%@", arguments: [ss])
        print(postString)
        
        request.httpBody = postString.data(using: .utf8)
        //        request.addValue("delta141forceSEAL8PARA9MARCOSBRAHMOS", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil
                else
            {
                print("error=\(String(describing: error))")
                return
            }
            
            do
            {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print(" Response------: \(String(describing: json))")
                //                let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                //                print(dictionary)
                //
                //                let status = dictionary.value(forKey: "status") as! String
                //                let sts = Int(status)
                //                DispatchQueue.main.async()
                //                    {
                //                        if sts == 200
                //                        {
                //                            print(dictionary)
                //                        }
                //                        else
                //                        {
                //                            print("OK")
                ////                            self.alertMessageOk(title: self.Alert!, message: dictionary.value(forKey: "message") as! String)
                //                        }
                //                }
            }
            catch
            {
                print(error)
            }
            
        }
        task.resume()
    }
    
    @IBAction func showWifi(_ sender: Any) {
        
    }
}
    
//    func calculateNextNumber() {
//        let result = current.adding(previous)
//
//        let bigNumber = NSDecimalNumber(mantissa: 1, exponent: 40, isNegative: false)
//        if result.compare(bigNumber) == .orderedAscending {
//            previous = current
//            current = result
//            position += 1
//        } else {
//            // This is just too much.... Start over.
//            resetCalculation()
//        }
//
//        let resultsMessage = "Position \(position) = \(current)"
//
//        switch UIApplication.shared.applicationState {
//        case .active:
//            print("asd")
////            resultsLabel.text = resultsMessage
//        case .background:
//            print("App is backgrounded. Next number = \(resultsMessage)")
//            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
//        case .inactive:
//            break
//        }
//    }
    
    
    
//print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



extension mainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        self.mostRecentLocation = locations.last!
        self.mostRecentSpeed = mostRecentLocation.speed
        self.mostRecentAltitude = mostRecentLocation.altitude
        
        print(mostRecentLocation.altitude)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = mostRecentLocation.coordinate
//        // Also add to our map so we can remove old values later
//        self.locations.append(annotation)
        
        // Remove values if the array is too big
//        while locations.count > 100 {
//            let annotationToRemove = self.locations.first!
//            self.locations.remove(at: 0)
//            // Also remove from the map
//            // mapView.removeAnnotation(annotationToRemove)
//        }
        if UIApplication.shared.applicationState == .active {
            //                mapView.showAnnotations(self.locations, animated: true)
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
    
}
