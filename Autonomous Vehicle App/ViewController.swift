//
//  ViewController.swift
//  Autonomous Vehicle App
//
//  Created by Ben Gilliam, JMU '18 on 1/24/18.
//

import UIKit
import MapKit
import GoogleMaps

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var statusSensor_01: UILabel!
    @IBOutlet weak var statusSensor_02: UILabel!
    @IBOutlet weak var statusSensor_03: UILabel!
    @IBOutlet weak var statusSensor_04: UILabel!
    @IBOutlet weak var statusSensor_05: UILabel!
    @IBOutlet weak var statusSensor_06: UILabel!
    
    //the json file url
    let URL_LOCATIONS = "http://educ.jmu.edu/~gilliabb/Inbox/locations.json";
    
    //A string array to save all the names
    var nameArray = [String]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        
        //set scrollview height
        ScrollView?.contentSize.height = 1000
        
        //requesting user location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        //setting desired location accuracy
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //loading functions
        sideMenus()
        customizeNavBar()
        getJsonFromUrl()
        onLoadMapView()
        displaySensorData()
        displayAppInfo()
        //googleMapsTest()
        //mapPolylineView(buttonNo: 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Cut Off button onClick functions
    @IBAction func cutOffButton(_ sender: UIButton) {
        cutOffAlert()
    }
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        //creating a NSURL
        let url = NSURL(string: URL_LOCATIONS)
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                //printing the json in console
                print(jsonObj!.value(forKey: "locations")!)
                
                //getting the avengers tag array from json and converting it to NSArray
                if let locationsArray = jsonObj!.value(forKey: "locations") as? NSArray {
                    //looping through all the elements
                    for location in locationsArray{
                        
                        //converting the element to a dictionary
                        if let locationDict = location as? NSDictionary {
                            
                            //getting the name from the dictionary
                            if let name = locationDict.value(forKey: "name") {
                                
                                //adding the name to the array
                                self.nameArray.append((name as? String)!)
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
    
    //function to create buttons from returned api data
    func createDynamicButtons() {
        
        var toGoButtonHeight = 64
        
        for name in nameArray{
            
            let toGoButton = UIButton(frame: CGRect(x: 0, y: toGoButtonHeight, width: 320, height: 48))
            toGoButton.setTitle(name, for: .normal)
            //toGoButton.backgroundColor = .white
            toGoButton.setBackgroundImage(UIImage(named: "white"), for: .normal)
            toGoButton.setBackgroundImage(UIImage(named: "highlight"), for: .selected)
            toGoButton.setTitleColor(UIColor.black, for: .normal)
            toGoButton.layer.borderColor = UIColor(displayP3Red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
            toGoButton.layer.borderWidth = 1
            toGoButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            self.view.addSubview(toGoButton)
            toGoButtonHeight = toGoButtonHeight + 47
        }
    }
    @objc func buttonAction(sender: UIButton) {
        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let newViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        //self.present(newViewController, animated: true, completion: nil)
        goAlert(buttonNo: 1)
    }
    
    // jmu*Location = various coordinates of JMU POIs
    let jmuXlabsLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.431928, -78.875965)
    let jmuFestivalLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.432766, -78.859402)
    let jmuMadisonUnionLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.437708, -78.870807)
    let jmuQuadLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(38.438833, -78.874412)
    
    //function that controls map annotations
    func onLoadMapView() {
        //distanceSpan = ~map altitude
        let distanceSpan:CLLocationDegrees = 500
        
        //jmu*Pin = location pins that will be placed on the map
        let jmuXlabsLocationPin = MapAnnotation(title: "JMU X-Labs", subtitle: "Lakeview Hall 1150", coordinate: jmuXlabsLocation)
        let jmuFestivalLocationPin = MapAnnotation(title: "Festival", subtitle: "Festival Conference Center", coordinate: jmuFestivalLocation)
        let jmuMadisonUnionLocationPin = MapAnnotation(title: "Madison Union", subtitle: "Madison Union", coordinate: jmuMadisonUnionLocation)
        let jmuQuadLocationPin = MapAnnotation(title: "The Quad", subtitle: "The Quad", coordinate: jmuQuadLocation)
        
        //setting initial place where map will load
        mapView?.setRegion(MKCoordinateRegionMakeWithDistance(jmuXlabsLocation, distanceSpan, distanceSpan), animated: true)
        
        //adding location pins to map
        mapView?.addAnnotation(jmuXlabsLocationPin)
        mapView?.addAnnotation(jmuFestivalLocationPin)
        mapView?.addAnnotation(jmuMadisonUnionLocationPin)
        mapView?.addAnnotation(jmuQuadLocationPin)
    }
    
    //function that controls the display of directions between user location and POI
    func mapPolylineView(buttonNo: NSNumber) {
        let sourceCoordinates = locationManager.location?.coordinate
        var destCoordinates = jmuFestivalLocation
        
        if buttonNo == 1 {
            destCoordinates = jmuXlabsLocation
            print("go to xlabs")
        } else if buttonNo == 2 {
            destCoordinates = jmuFestivalLocation
            print("go to festi")
        } else if buttonNo == 3 {
            destCoordinates = jmuMadisonUnionLocation
            print("go to mu")
        } else if buttonNo == 4 {
            destCoordinates = jmuQuadLocation
            print("go to quad")
        }
        
        print(destCoordinates)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else {
                if error != nil {
                    print("Something went wrong")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView?.add(route.polyline, level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            self.mapView?.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        })
    }
    
    //function that displays polyline between user location and POI
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(displayP3Red: 69/255, green: 0/255, blue: 132/255, alpha: 1)
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    //function to display sensor data
    func displaySensorData() {
        self.statusSensor_01?.text = "37V"
        self.statusSensor_02?.text = "Good"
        self.statusSensor_03?.text = "Good"
        self.statusSensor_04?.text = "Good"
        self.statusSensor_05?.text = "Good"
        self.statusSensor_06?.text = "Good"
    }
    
    //function that displays cut off alert
    func cutOffAlert() {
        let alert = UIAlertController(title: "Cut off vehicle power?", message: "Are you sure you wish to cut off vehicle power?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            //code that cuts off car's power
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //function that displays go to alert
    func goAlert(buttonNo: NSNumber) {
        let alert = UIAlertController(title: "Go to this destination?", message: "The vehicle will drive itself to your chosen destination", preferredStyle: .alert)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let goToViewController = storyboard.instantiateViewController(withIdentifier: "GoToViewController") as UIViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { (action) in
            if buttonNo == 1 {
                self.mapPolylineView(buttonNo: 1)
            } else if buttonNo == 2 {
                self.mapPolylineView(buttonNo: 2)
            } else if buttonNo == 3 {
                self.mapPolylineView(buttonNo: 3)
            } else if buttonNo == 4 {
                self.mapPolylineView(buttonNo: 4)
            }
            //alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            appDelegate.window?.rootViewController = goToViewController
        }))
        
        self.present(alert, animated: true)
        }
    
    func googleMapsTest() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate 38.431928,-78.875965 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 38.431928, longitude: -78.875965, zoom: 6.0)
        let gmapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = gmapView
        
        // Creates a marker in the center of the map.
        let jmuXlabsLocationMarker = GMSMarker()
        jmuXlabsLocationMarker.position = CLLocationCoordinate2D(latitude: 38.431928, longitude: -78.875965)
        jmuXlabsLocationMarker.title = "JMU X-Labs"
        jmuXlabsLocationMarker.snippet = "Lakeview Hall 1150"
        jmuXlabsLocationMarker.map = gmapView
        
        let jmuFestivalLocationMarker = GMSMarker()
        jmuFestivalLocationMarker.position = CLLocationCoordinate2D(latitude: 38.432766, longitude: -78.859402)
        jmuFestivalLocationMarker.title = "Festival"
        jmuFestivalLocationMarker.snippet = "Festival Conference Center"
        jmuFestivalLocationMarker.map = gmapView
        
        let jmuMadisonUnionLocationMarker = GMSMarker()
        jmuMadisonUnionLocationMarker.position = CLLocationCoordinate2D(latitude: 38.437708, longitude: -78.870807)
        jmuMadisonUnionLocationMarker.title = "Madison Union"
        jmuMadisonUnionLocationMarker.snippet = "Madison Union"
        jmuMadisonUnionLocationMarker.map = gmapView
        
        let jmuQuadLocationMarker = GMSMarker()
        jmuQuadLocationMarker.position = CLLocationCoordinate2D(latitude: 38.438833, longitude: -78.874412)
        jmuQuadLocationMarker.title = "The Quad"
        jmuQuadLocationMarker.snippet = "The Quad"
        jmuQuadLocationMarker.map = gmapView
    }
    
    //function that control side menu interaction
    func sideMenus() {
        
        if revealViewController() != nil {
            menuButton?.target = revealViewController()
            menuButton?.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    //function that customises nav bar colours for icons, background and text
    func customizeNavBar() {
        //bar icon colour
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //bar background colour
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 0/255, green: 150/255, blue: 255/255, alpha: 1)
        
        //bar text colour
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    //function to dynamically add app info
    func displayAppInfo() {
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let versionAndBuildNumber = "\(appVersionString) (\(buildNumber))"
        self.appVersionLabel?.text = versionAndBuildNumber
    }
}
