//
//  NotificationsViewController.swift
//  Access Algarve
//
//  Created by Daniel on 25/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var appnotifications = [AppNotification]()
    var currentColor: UIColor!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var notificationsTableView: UITableView!
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    //: Define Colors
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appnotifications.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationsTableViewCell
        DispatchQueue.main.async() {
            if (self.appnotifications[indexPath.row].image_url != nil) {cell.notificationImage.downloadedFrom(link: "\(self.appnotifications[indexPath.row].image_url)")}
            cell.notificationTitle.text = self.appnotifications[indexPath.row].title
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //currentColor = invisible

        self.notificationsTableView.delegate = self
        self.notificationsTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Initiate loader
        setLoadingScreen()
        
        //: Load first set of results
        loadResults()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currentLocation = location
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueidentifier = segue.identifier else {return}
        if segueidentifier == "showFavourites" {
            guard let favouritesViewController = segue.destination as? FavouritesViewController else {return}
            favouritesViewController.currentLocation = currentLocation
        }
    }
    
    private func loadResults() -> Void {
        
        //let params = ["user_id": 1]
        getAPIResults(endpoint: "notifications", parameters:[:]) { data in
            do {
                //: Load the results
                let appnotificationstmp: [AppNotification]! = try [AppNotification].decode(data: data)
                self.appnotifications = appnotificationstmp
                DispatchQueue.main.async {
                    self.notificationsTableView.reloadData()
                    self.removeLoadingScreen()
                }
            } catch {
                print("Error decoding Notifications data")
            }
        }
        
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        //Hide the tableView
        //notificationsTableView.separatorColor = invisible
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (notificationsTableView.frame.width / 2) - (width / 2)
        let y = (notificationsTableView.frame.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.activityIndicatorViewStyle = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        notificationsTableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        //notificationsTableView.separatorColor = currentColor
        
    }

}
