//
//  ProfileSettingsViewController.swift
//  Access Algarve
//
//  Created by Daniel Santos on 02/04/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SwiftyJSON
import QuartzCore

class ProfileSettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var user: User!
    var countries: JSON!
    var senderField: UITextField!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userBirthday: UITextField!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userNationality: UITextField!
    @IBOutlet weak var userCountry: UITextField!
    @IBOutlet weak var userNotifications: UISwitch!
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var countryPickerView: UIView!
    @IBOutlet weak var countryPicker: UIPickerView!
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
//        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
//            nextField.becomeFirstResponder()
//        } else {
//            // Not found, so remove keyboard.
//            textField.resignFirstResponder()
//        }
        
        textField.resignFirstResponder()
        //self.view.endEditing(true)
        
        // Do not add a line break
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.datePickerView.isHidden = true
        self.countryPickerView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.countries[row]["name"]["common"].string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.senderField.text = self.countries[row]["name"]["common"].string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countryPicker.delegate = self
        self.countryPicker.dataSource = self
        
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                self.user = try User.decode(data: savedUser)
                userName.text = user.name
                userEmail.text = user.email
                userBirthday.text = user.birthday
                userMobile.text = user.mobile
                userNationality.text = user.nationality
                userCountry.text = user.country
                if user.notifications == 1 {userNotifications.isOn = true} else {userNotifications.isOn = false}
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        
        //Load coutries file
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonCountries = try JSON(data: data)
                self.countries = jsonCountries
            } catch {
                print("Error getting countries from JSON file")
            }
        }

    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        //: Save settings and go back
        do {
            self.user.name = self.userName.text!
            self.user.email = self.userEmail.text!
            self.user.birthday = self.userBirthday.text!
            self.user.mobile = self.userMobile.text!
            self.user.nationality = self.userNationality.text!
            self.user.country = self.userCountry.text!
            if self.userNotifications.isOn {self.user.notifications = 1} else {self.user.notifications = 0}
            let encodedUser = try self.user.encode()
            let defaults = UserDefaults.standard
            defaults.set(encodedUser, forKey: "SavedUser")
            DispatchQueue.main.async {
                var params = [
                    "name": self.userName.text!,
                    "email": self.userEmail.text!,
                    "birthday": self.userBirthday.text!,
                    "mobile": self.userMobile.text!,
                    "nationality": self.userNationality.text!,
                    "country": self.userCountry.text!
                ] as [String : Any]
                if self.userNotifications.isOn {params["notifications"] = 1} else {params["notifications"] = 0}
                self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {_ in }
                self.performSegue(withIdentifier: "unwindToSettingsSegue", sender: self)
            }
        } catch {
            print("Error encoding user data to defaults")
        }
        
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        if sender.tag == 3 {
            sender.resignFirstResponder()
            sender.superview?.endEditing(true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let selectedDate = formatter.date(from: self.userBirthday.text!)
            self.datePicker.date = selectedDate!
            self.datePickerView.isHidden = false
        } else if sender.tag == 5 || sender.tag == 6 {
            sender.resignFirstResponder()
            sender.superview?.endEditing(true)
            var selectedRow: Int!
            for (index, country) in (self.countries.array?.enumerated())! {
                if country["name"]["common"].string == sender.text {
                    selectedRow = index
                }
            }
            self.countryPicker.selectRow(selectedRow, inComponent: 0, animated: true)
            self.senderField = sender
            self.countryPickerView.isHidden = false
        }
    }
    @IBAction func closeDatePickerClicked(_ sender: UIButton) {
        self.datePickerView.isHidden = true
    }
    @IBAction func closeCountryPickerClicked(_ sender: UIButton) {
        self.countryPickerView.isHidden = true
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: sender.date)
        self.userBirthday.text = selectedDateString
    }
    
}
