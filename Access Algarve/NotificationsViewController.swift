//
//  NotificationsViewController.swift
//  Access Algarve
//
//  Created by Daniel on 25/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var appnotifications = [AppNotification]()
    var currentColor: UIColor!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    @IBOutlet var notificationsTableView: UITableView!
    @IBOutlet var noNotificationsMessage: UILabel!
    
    //: Define Colors
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appnotifications.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationsTableViewCell
        DispatchQueue.main.async() {
            //if (self.appnotifications[indexPath.row].image_url != nil) {cell.notificationImage.downloadedFrom(link: "\(self.appnotifications[indexPath.row].image_url)")}
            cell.notificationTitle.text = self.appnotifications[indexPath.row].title
            cell.notificationDescription.text = self.appnotifications[indexPath.row].description
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentColor = invisible

        self.notificationsTableView.delegate = self
        self.notificationsTableView.dataSource = self
        self.locationManager.delegate = self
        
        //: Handle location
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //: Initiate loader
        DispatchQueue.main.async {
            self.notificationsTableView.separatorColor = self.invisible
            SVProgressHUD.show(withStatus: "Loading")
        }
        
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
    
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? NotificationsTableViewCell else {return}
        if let indexPath = notificationsTableView?.indexPath(for: cell) {
            if appnotifications[indexPath.row].destination_url != nil {
                if let url = URL(string: appnotifications[indexPath.row].destination_url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    private func loadResults() -> Void {
        
        //let params = ["user_id": 1]
        getAPIResults(endpoint: "notifications", parameters: nil) { data in
            do {
                //: Load the results
                self.appnotifications = try [AppNotification].decode(data: data)
                DispatchQueue.main.async {
                    self.notificationsTableView.reloadData()
                    SVProgressHUD.dismiss()
                    if self.appnotifications.count == 0 {self.noNotificationsMessage.isHidden = false}
                }
            } catch {
                print("Error decoding Notifications data")
            }
        }
        
    }

}
