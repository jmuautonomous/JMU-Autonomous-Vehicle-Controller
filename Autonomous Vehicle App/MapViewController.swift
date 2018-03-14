//
//  ViewController.swift
//  Autonomous Vehicle App
//
//  Created by Ben Gilliam, JMU '18 on 2/20/18.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem?
    @IBOutlet var mapView: MKMapView?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        
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
        onLoadMapView()
        addMapTrackingButton()
        //if LocationsViewController != nil {
        //    mapPolylineView(buttonNo: LocationsViewController.buttonAction(<#T##LocationsViewController#>))
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Cut Off button onClick functions
    @IBAction func cutOffButton(_ sender: UIButton) {
        cutOffAlert()
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
    
    func addMapTrackingButton(){
        let image = UIImage(named: "trackme") as UIImage?
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        button.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 35, height: 35))
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(MapViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
        mapView?.addSubview(button)
    }
    
    @objc func centerMapOnUserButtonClicked() {
        mapView?.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
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
}
