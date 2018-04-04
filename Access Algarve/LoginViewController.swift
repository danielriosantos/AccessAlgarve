//
//  LoginViewController.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 17/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKLoginKit
import SwiftyJSON

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var user: User!
    
    let fbLoginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email"]
        return button
    }()
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("FB Account Logged Out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Logging In")}
        fetchProfile()
        print("FB Login Success")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginButton.delegate = self
        self.view.addSubview(fbLoginButton)
        fbLoginButton.frame = CGRect(x: 0, y: loginButton.frame.origin.y + loginButton.frame.height + 5, width: 190, height: 35)
        fbLoginButton.center.x = self.view.center.x
        
    }
    
    func fetchProfile() {
        let params = ["fields": "id, name, email, first_name, last_name, age_range, link, gender, locale, timezone, picture.type(large), updated_time, verified"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: {
            (connection, result, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                let json = JSON(result!)
                print(json)
                let email = json["email"].stringValue
                
                //: Check if user exists in database, otherwise create it
                self.getAPIResults(endpoint: "users", parameters: ["email": email]) {data in
                    do {
                        let users: [User] = try [User].decode(data: data)
                        if users.count > 0 {
                            self.user = users[0]
                            self.user.status = 1
                            //: Save user status on UserDefaults
                            let encodedUser = try self.user.encode()
                            let defaults = UserDefaults.standard
                            defaults.set(encodedUser, forKey: "SavedUser")
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                let params = ["status": 1]
                                self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {_ in}
                                self.performSegue(withIdentifier: "correctCredentialsSegue", sender: self)
                            }
                        } else {
                            //: User does not exist, use facebook data to create it and log in
                            let params = [
                                "name": json["name"].stringValue,
                                "email": json["email"].stringValue
                            ]
                            self.postAPIResults(endpoint: "users", parameters: params) { data in
                                DispatchQueue.main.async {
                                    do {
                                        //: Save user in app defaults
                                        self.user = try User.decode(data: data)
                                        //self.user.status = 0
                                        //self.user.country = self.country.text
                                        let defaults = UserDefaults.standard
                                        let encodedUser = try self.user.encode()
                                        defaults.set(encodedUser, forKey: "SavedUser")
                                        SVProgressHUD.dismiss()
                                        self.performSegue(withIdentifier: "createAccountSegue", sender: self)
                                    } catch {
                                        //: Alert wrong user pass message
                                        SVProgressHUD.dismiss()
                                        let alert = UIAlertController(title: "Error", message: "Error Creating Your Account. The account you're trying to create might already exist or please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    } catch {
                        //: Authentication was wrong, alert user
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Error", message: "There was an eror logging in with your facebook, please try again later", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
            }
            
            
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "licenseSegue" {
            guard let licenseViewController = segue.destination as? LicenseViewController else {return}
            licenseViewController.previousVC = "login"
        } else if segue.identifier == "showForgotPassword" {
            guard let forgotPasswordViewController = segue.destination as? ForgotPasswordViewController else {return}
            forgotPasswordViewController.previousVC = "login"
        }
    }
    
    @IBAction func checkLoginCredentials(_ sender: UIButton) {
        DispatchQueue.main.async {SVProgressHUD.show(withStatus: "Loading")}
        let params = ["email": email.text!, "password": password.text!]
        postAPIResults(endpoint: "users/authenticate", parameters: params) { data in
            do {
                //: Try to decode user if authentication is correct
                print(String(data: data, encoding: .utf8)!)
                self.user = try User.decode(data: data)
                self.user.status = 1
                //: Save user status on UserDefaults
                let encodedUser = try self.user.encode()
                let defaults = UserDefaults.standard
                defaults.set(encodedUser, forKey: "SavedUser")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let params = ["status": 1]
                    self.putAPIResults(endpoint: "users/" + String(self.user.id), parameters: params) {_ in}
                    self.performSegue(withIdentifier: "correctCredentialsSegue", sender: self)
                }
            } catch {
                //: Authentication was wrong, alert user
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "The email and password provided were not recognized", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func unwindToLoginViewController(_ segue: UIStoryboardSegue) {
        
    }

}
