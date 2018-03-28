//
//  DatabaseExtension.swift
//  Access Algarve Light
//
//  Created by Daniel Santos on 06/03/2018.
//  Copyright © 2018 Daniel Santos. All rights reserved.
//

import Foundation

struct Redemption: Codable {
    let id: Int
    let user_id: Int
    let offer_id: Int
    let subscription_id: Int
    let created_at: String
    let updated_at: String
    let offer: Offer!
}

struct Subscription: Codable {
    let id: Int
    let user_id: Int
    let product_id: Int
    let start_date: String!
    let end_date: String!
    let status: Int
    let created_at: String
    let updated_at: String
    let product: Product!
}

struct Product: Codable {
    let id: Int
    let code: String
    let name: String
    let price: String
    let start_date: String
    let end_date: String
    let status: Int
    let created_at: String
    let updated_at: String
}

struct UserFavourite: Codable {
    let id: Int
    let user_id: Int
    var outlet_id: Int
    let created_at: String
    let updated_at: String
    var outlet: Outlet!
}

public struct User: Codable {
    let id: Int
    var name: String
    var email: String
    var password: String!
    var pin: String!
    var country: String!
    var status: Int!
    var excluded_locations: [String]!
    let created_at: String
    let updated_at: String
    let subscriptions: [Subscription]!
    let redemptions: [Redemption]!
    var favourites: [UserFavourite]!
}

struct Merchant: Codable {
    let id: Int
    let name: String
    let description: String
    let pin: String
    let status: Int
    let created_at: String
    let updated_at: String
    let deleted_at: String!
}

struct Category: Codable {
    let id: Int
    let name: String
    let status: Int
}

struct Type: Codable {
    let id: Int
    let name: String
    let status: Int
}

struct Offer: Codable {
    
    let id: Int
    let merchant_id: Int
    let outlet_id: Int
    let offer_category_id: Int
    let offer_type_id: Int
    let name: String
    let description: String
    let offer_heading: String!
    let offer_type: String!
    let start_date: String
    let end_date: String
    var max_savings: String
    var quantity: Int
    let status: Int
    let created_at: String
    let updated_at: String
    let deleted_at: String!
    let outlet: Outlet!
    let category: Category!
    let type: Type!
    
}

struct Outlet: Codable {
    let id: Int
    let merchant_id: Int
    let name: String
    let phone: String
    let address: String
    let city: String
    let postcode: String
    let region: String
    let country: String
    let gps: String
    let email: String
    let website: String
    let facebook: String
    let opening_times: String
    let amenities: [Int]
    let pin: String
    let status: Int
    let created_at: String
    let updated_at: String
    let deleted_at: String!
    let merchant: Merchant!
    let offers: [Offer]!
}

struct OutletResults: Codable {
    let current_page: Int
    let data: [Outlet]
    let first_page_url: String
    let from: Int!
    let last_page: Int
    let last_page_url: String
    let next_page_url: String!
    let path: String
    let per_page: Int
    let prev_page_url: String!
    let to: Int!
    let total: Int
}

struct Location: Codable {
    var city: String
    var status: Bool!
}

struct AppNotification: Codable {
    let id: Int
    let user_id: Int!
    let product_id: Int!
    let merchant_id: Int!
    let outlet_id: Int!
    let offer_id: Int!
    let title: String
    let description: String!
    let image_url: String!
    let destination_url: String!
    let created_at: String
    let updated_at: String
}

struct KeyValuePair<T: Codable>: Codable {
    var key: String?
    var value: T?
}

//: Decodable Extension
extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

//: Encodable Extension
extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}

/*
extension JSONEncoder {
    func encodeJSONObject<T: Encodable>(_ value: T, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: opt)
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, withJSONObject object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try decode(T.self, from: data)
    }
}
*/
