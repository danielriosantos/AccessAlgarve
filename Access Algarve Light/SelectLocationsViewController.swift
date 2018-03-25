//
//  SelectLocationsViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 20/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit

class SelectLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var locationsTable: UITableView!
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var user: User!
    var locations: [Location]! = []
    let currentColor = UIColor(red: 186.0/255.0, green: 186.0/255.0, blue: 186.0/255.0, alpha: 1.0)
    let invisible = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = locationsTable.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationsTableViewCell
        DispatchQueue.main.async() {
            cell.location.text = self.locations[indexPath.row].city
            if self.user.excluded_locations?.count != nil {
                if self.user.excluded_locations.contains(self.locations[indexPath.row].city) {
                    cell.status.isOn = false
                }
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationsTable.delegate = self
        self.locationsTable.dataSource = self
        
        //: Load user previous location save
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                user = try User.decode(data: savedUser)
                if user.excluded_locations == nil {
                    user.excluded_locations = []
                }
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        
        //: Initiate loader
        setLoadingScreen()
        
        //: Load first set of results
        loadResults()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //: Save user alterations on UserDefaults
        let defaults = UserDefaults.standard
        do {
            let encodedUser = try user.encode()
            defaults.set(encodedUser, forKey: "SavedUser")
        } catch {
            print("Error encoding user data")
        }
    }
    
    @IBAction func locationSwitchChanged(_ sender: UISwitch) {
        guard let cell = sender.superview?.superview as? LocationsTableViewCell else {return}
        if let indexPath = locationsTable?.indexPath(for: cell) {
            if !sender.isOn {
                user.excluded_locations.append(locations[indexPath.row].city)
            } else {
                for (index, loc) in user.excluded_locations.enumerated() {
                    if loc == locations[indexPath.row].city {
                        user.excluded_locations.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func loadResults() -> Void {
        
        getAPIResults(endpoint: "outlets/locations", parameters: [:]) { data in
            do {
                //: Load the results
                let locationsResults = try [Location].decode(data: data)
                self.locations.append(contentsOf: locationsResults)
                DispatchQueue.main.async {
                    self.locationsTable.reloadData()
                    self.removeLoadingScreen()
                }
            } catch {
                print("Error decoding Locations data")
            }
        }
        
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        //Hide the tableView
        locationsTable.separatorColor = invisible
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (locationsTable.frame.width / 2) - (width / 2)
        let y = (locationsTable.frame.height / 2) - (height / 2)
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
        
        locationsTable.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        locationsTable.separatorColor = currentColor
        
    }

}
