//
//  ViewController.swift
//  Autonomous Vehicle App
//
//  Created by Ben Gilliam, JMU '18 on 3/1/18.
//

import UIKit
import MapKit
import SystemConfiguration

class LocationsViewController: UIViewController {
    
    //A string array to save all the names
    var nameArray = [String]()
    var idArray = [Int]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //requesting user location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        //setting desired location accuracy
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRefresh))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        //loading functions
        getJsonFromUrl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        return (isReachable)
    }
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        //creating a NSURL
        let url = NSURL(string: GoToViewController.ApiUrl.url + "locations")
        if isInternetAvailable() == true {
            //fetching the data from the url
            URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    //printing the json in console
                    print(jsonObj!.value(forKey: "Locations")!)
                    
                    //getting the avengers tag array from json and converting it to NSArray
                    if let locationsArray = jsonObj!.value(forKey: "Locations") as? NSArray {
                        
                        //looping through all the elements
                        for location in locationsArray{
                            
                            //converting the element to a dictionary
                            if let locationDict = location as? NSDictionary {
                                
                                //getting the name from the dictionary
                                if let name = locationDict.value(forKey: "name") {
                                    
                                    //adding the name to the array
                                    self.nameArray.append((name as? String)!)
                                }
                                
                                //getting the id from the dictionary
                                if let id = locationDict.value(forKey: "id") {
                                    
                                    //adding the id to the array
                                    self.idArray.append(id as! Int)
                                }
                            }
                        }
                    }
                    
                    OperationQueue.main.addOperation({
                        //calling another function after fetching the json
                        //it will show the names to label
                        self.createDynamicButtons()
                    })
                }
            }).resume()
        }
    }
    
    //function to create buttons from returned api data
    func createDynamicButtons() {
        
        var toGoButtonHeight = 0
        var buttonId: Int = 1
        
        for name in nameArray {
            let toGoButton = UIButton(frame: CGRect(x: 0, y: toGoButtonHeight, width: 770, height: 48))
            toGoButton.setTitle(name, for: .normal)
            toGoButton.tag = buttonId
            toGoButton.contentHorizontalAlignment = .left
            toGoButton.titleEdgeInsets.left = 20
            toGoButton.setBackgroundImage(UIImage(named: "white"), for: .normal)
            toGoButton.setBackgroundImage(UIImage(named: "highlight"), for: .selected)
            toGoButton.setTitleColor(UIColor.black, for: .normal)
            toGoButton.layer.borderColor = UIColor(displayP3Red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
            toGoButton.layer.borderWidth = 1
            toGoButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            self.view.addSubview(toGoButton)
            toGoButtonHeight = toGoButtonHeight + 47
            buttonId = buttonId + 1
        }
    }
    @objc func buttonAction(sender: UIButton) {
        goAlert(buttonNo: (sender.tag as NSNumber))
    }
    
    //function that displays go to alert
    func goAlert(buttonNo: NSNumber) {
        let alert = UIAlertController(title: "Go to this destination?", message: "The vehicle will drive itself to your chosen destination", preferredStyle: .alert)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! SWRevealViewController
        
        alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { (action) in
            self.present(mapViewController, animated:true, completion:nil)
            MapViewController().mapPolylineView(buttonNo: buttonNo)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc func swipeToRefresh(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let goToViewController = storyboard.instantiateViewController(withIdentifier: "GoToViewController") as UIViewController
            
            self.present(goToViewController, animated:false, completion:nil)
            print("view refreshed")
        }
    }
}

