//
//  BackendAPIAdapter.swift
//  Standard Integration (Swift)
//
//  Created by Ben Guo on 4/15/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import SwiftyJSON

class MyAPIClient: NSObject, STPEphemeralKeyProvider {

    static let sharedClient = MyAPIClient()
    
    var user: User!
    var customerID: String = ""
    var baseURLString: String? = nil
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func completeCharge(_ result: STPPaymentResult, amount: Int, requestparams: [String: Any], completion: @escaping STPErrorBlock) {

        guard let token = Bundle.main.object(forInfoDictionaryKey: "API Token") as? String else {return}
        let url = self.baseURL.appendingPathComponent("createstripecharge")
        var params: [String : Any] = requestparams
        params["customer"] = self.customerID
        params["amount"] = amount
        let headers = [
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                print(responseJSON)
                switch responseJSON.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }

    }

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "API Token") as? String else {return}
        let url = self.baseURL.appendingPathComponent("createstripeephemeralkey/" + String(self.user.id))
        let params = [
            "api_version": apiVersion
        ] as [String : Any]
        let headers = [
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { responseData in
                switch responseData.result {
                case .success(let json):
                    let jsonresult = JSON(json)
                    self.customerID = jsonresult["associated_objects"][0]["id"].string!
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }

}
