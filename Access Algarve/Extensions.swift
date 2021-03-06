//
//  Extensions.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 16/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

extension UIViewController {
    
    public func loadUser() {
        var user: User!
        let defaults = UserDefaults.standard
        if let savedUser = defaults.object(forKey: "SavedUser") as? Data {
            do {
                user = try User.decode(data: savedUser)
            } catch {
                print("Error decoding user data from defaults")
            }
        }
        loadUser(user_id: user.id) {_ in}
    }
    
    public func loadUser(user_id: Int, completion: @escaping (User)->()) {
        getAPIResults(endpoint: "users/" + String(user_id), parameters: nil) { userData in
            do {
                let defaults = UserDefaults.standard
                defaults.set(userData, forKey: "SavedUser")
                let user: User = try User.decode(data: userData)
                completion(user)
            } catch {
                print("Error decoding user from database")
            }
        }
    }
    
    public func hasValidSubscription(forUser: User) -> Bool {
        var validSubscription = false
        let date = Date()
        for subscription in forUser.subscriptions {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "UTC")
            let subscriptionFromDate = formatter.date(from: subscription.start_date)!
            let subscriptionToDate = formatter.date(from: subscription.end_date)!
            if date >= subscriptionFromDate && date <= subscriptionToDate && subscription.status == 1 {validSubscription = true}
        }
        return validSubscription
    }
    
    public func countValidSubscription(forUser: User) -> Int {
        var validSubscriptionCounter: Int = 0
        let date = Date()
        for subscription in forUser.subscriptions {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "UTC")
            let subscriptionFromDate = formatter.date(from: subscription.start_date)!
            let subscriptionToDate = formatter.date(from: subscription.end_date)!
            if date >= subscriptionFromDate && date <= subscriptionToDate && subscription.status == 1 {validSubscriptionCounter += 1}
        }
        return validSubscriptionCounter
    }
    
    public func getEasyPayPaymentIdentifier(parameters: [String:Any]?, completion: @escaping (Data)->()) {
        let scheme = "https"
        let host = "www.easypay.pt"
        let path = "/_s/api_easypay_01BG.php"
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        if parameters != nil {
            urlComponents.queryItems = []
            for parameter in parameters! {
                let queryItem = URLQueryItem(name: parameter.key, value: String(describing: parameter.value))
                urlComponents.queryItems?.append(queryItem)
            }
        }
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = data {
                //let utf8Representation = String(data: data, encoding: .utf8)
                //print("response: ", utf8Representation)
                completion(data)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()

    }
    
    public func getAPIResults(endpoint: String, parameters: [String:Any]?, completion: @escaping (Data)->()) {
        requestAPIResults(type: "GET", endpoint: endpoint, parameters: parameters) { data in
             completion(data)
        }
    }
    
    public func postAPIResults(endpoint: String, parameters:[String:Any]?, completion: @escaping (Data)->()) {
        requestAPIResults(type: "POST", endpoint: endpoint, parameters: parameters) { data in
            completion(data)
        }
    }
    
    public func putAPIResults(endpoint: String, parameters: [String:Any]?, completion: @escaping (Data)->()) {
        requestAPIResults(type: "PUT", endpoint: endpoint, parameters: parameters) { data in
            completion(data)
        }
    }
    
    public func deleteAPIResults(endpoint: String, parameters: [String:Any]?, completion: @escaping (Data)->()) {
        requestAPIResults(type: "DELETE", endpoint: endpoint, parameters: nil) { data in
            completion(data)
        }
    }
    
    private func requestAPIResults(type: String, endpoint: String, parameters: [String:Any]?, completion: @escaping (Data)->() ) {
        
        let scheme = "https"
        let host = "admin.accessalgarve.com"
        let path = "/api/" + endpoint
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        if parameters != nil && type == "GET" {
            urlComponents.queryItems = []
            for parameter in parameters! {
                let queryItem = URLQueryItem(name: parameter.key, value: String(describing: parameter.value))
                urlComponents.queryItems?.append(queryItem)
            }
        }
        guard let token = Bundle.main.object(forInfoDictionaryKey: "API Token") as? String else {return}
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = type
        if parameters != nil && type != "GET" {
            do {
                //urlRequest.httpBody = try JSONStringify(value: parameters!).datify()
                urlRequest.httpBody = try JSON(parameters!).rawData(options: .prettyPrinted)
            } catch {
                print("Error encoding paramenters")
            }
            
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = data {
                //let utf8Representation = String(data: data, encoding: .utf8)
                //print("response: ", utf8Representation)
                completion(data)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
        
    }
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension UITextField {
    func shouldChangeCustomOtp(textField:UITextField, string: String) ->Bool {
        
        //Check if textField has one chacraters
        if ((textField.text?.count)! == 0  && string.count > 0) {
            let nextTag = textField.tag + 1;
            // get next responder
            var nextResponder = textField.superview?.viewWithTag(nextTag);
            if (nextResponder == nil) {
                nextResponder = textField.superview?.viewWithTag(1);
            }
            
            textField.text = textField.text! + string;
            //write here your last textfield tag
            if textField.tag == 4 {
                //Dissmiss keyboard on last entry
                textField.resignFirstResponder()
            }
            else {
                ///Appear keyboard
                nextResponder?.becomeFirstResponder();
            }
            return false;
        } else if ((textField.text?.count)! == 0  && string.count == 0) {// on deleteing value from Textfield
            
            let previousTag = textField.tag - 1;
            // get prev responder
            var previousResponder = textField.superview?.viewWithTag(previousTag);
            if (previousResponder == nil) {
                previousResponder = textField.superview?.viewWithTag(1);
            }
            textField.text = "";
            previousResponder?.becomeFirstResponder();
            return false
        }
        return true
        
    }
    
}
