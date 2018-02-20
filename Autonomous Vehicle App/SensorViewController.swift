//
//  ViewController.swift
//  Autonomous Vehicle App
//
//  Created by Ben Gilliam, JMU '18 on 2/20/18.
//

import UIKit

class SensorViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem?
    
    @IBAction func refreshViewButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sensorViewController = storyboard.instantiateViewController(withIdentifier: "SensorViewController") as UIViewController
        
        self.present(sensorViewController, animated:false, completion:nil)
        print("view refreshed")
    }
    
    @IBOutlet weak var statusSensor_01: UILabel!
    @IBOutlet weak var statusSensor_02: UILabel!
    @IBOutlet weak var statusSensor_03: UILabel!
    @IBOutlet weak var statusSensor_04: UILabel!
    @IBOutlet weak var statusSensor_05: UILabel!
    @IBOutlet weak var statusSensor_06: UILabel!
    
    //the json file url
    let mockApiURL = "https://d2d8164e-baeb-48cd-9f47-d974783abdc4.mock.pstmn.io/V1/";
    
    //A string array to save all the names
    var nameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loading functions
        sideMenus()
        customizeNavBar()
        getJsonFromUrl()
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
        let url = NSURL(string: mockApiURL + "sensors")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                //printing the json in console
                print(jsonObj!.value(forKey: "sensors")!)
                
                //getting the avengers tag array from json and converting it to NSArray
                if let sensorsArray = jsonObj!.value(forKey: "sensors") as? NSArray {
                    let sensorValues = sensorsArray.value(forKeyPath: "value.name") as! NSArray
                    
                    self.statusSensor_01?.text = sensorValues[0] as? String
                    self.statusSensor_02?.text = sensorValues[1] as? String
                    self.statusSensor_03?.text = sensorValues[2] as? String
                    self.statusSensor_04?.text = sensorValues[3] as? String
                    self.statusSensor_05?.text = sensorValues[4] as? String
                    self.statusSensor_06?.text = sensorValues[5] as? String
                }
            }
        }).resume()
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
