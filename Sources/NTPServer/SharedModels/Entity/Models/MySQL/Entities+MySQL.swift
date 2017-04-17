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
        // FIXME: not implemented stub
        let id = node["id"]!.string!
        let timestamp = node["timestamp"]!.int!
        let text = node["text"]!.string!
        self.init(id: id, timestamp: timestamp, text: text)
    }
}

extension App: MySQLInitializable {
    convenience init(with node: [String : Node]) {
        let id = node["id"]?.int
        let name = node["name"]!.string!
        let location = node["location"]!.string!
        let vendorId = node["vendor_id"]!.int!
        let status = node["status"]!.string!
        self.init(id: id, name: name, location: location, vendorId: vendorId, status: status)
    }
}

