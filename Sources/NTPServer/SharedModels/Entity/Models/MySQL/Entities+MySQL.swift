//
//  Entities+MySQL.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation
import MySQL

protocol MySQLInitializable {
    init(with node: [String: Node])
}

extension User: MySQLInitializable {
    convenience init(with node: [String: Node]) {
        let id = node["id"]?.int
        let login = node["login"]!.string!
        let email = node["email"]!.string!
        let password = node["password"]!.string!
        let salt = node["salt"]!.string!
        self.init(id: id, login: login, email: email, password: password, salt: salt)
    }
}

extension Vendor: MySQLInitializable {
    convenience init(with node: [String: Node]) {
        let id = node["id"]?.int
        let login = node["login"]!.string!
        let email = node["email"]!.string!
        let password = node["password"]!.string!
        let salt = node["salt"]!.string!
        let token = node["token"]!.string!
        self.init(id: id, login: login, email: email, password: password, salt: salt, token: token)
    }
}

extension Post: MySQLInitializable {
    convenience init(with node: [String: Node]) {
        let id = node["id"]!.string!
        let timestamp = node["timestamp"]!.int!
        let text = node["text"]!.string!
        let photoUrl = node["photo_url"]?.string
        self.init(id: id, timestamp: timestamp, text: text, photoUrl: photoUrl)
    }
}

extension App: MySQLInitializable {
    convenience init(with node: [String : Node]) {
        let id = node["id"]?.int
        let name = node["name"]!.string!
        let location = node["location"]!.string!
        let vendorId = node["vendor_id"]!.int!
        let status = node["status"]!.string!
        let socialGroup = node["social_group"]?.string
        self.init(id: id,
                  name: name,
                  location: location,
                  vendorId: vendorId,
                  status: status,
                  socialGroup: socialGroup)
    }
}

extension Category: MySQLInitializable {
    convenience init(with node: [String : Node]) {
        let id = node["id"]?.int
        let name = node["name"]!.string!
        let appId = node["app_id"]!.int!
        let socialGroupURL = node["social_group"]!.string!
        let socialNetworkId = node["social_network_id"]!.int!
        let filterQuery = node["filter_query"]?.string
        var filter: Filter?
        if let query = filterQuery {
            filter = Filter(query: query)
        }
        self.init(id: id,
                  name: name,
                  appId: appId,
                  socialGroupURL: socialGroupURL,
                  socialNetworkId: socialNetworkId,
                  filter: filter)
    }
}


