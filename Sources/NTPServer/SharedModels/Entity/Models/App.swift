//
//  App.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

enum AppStatus: String {
    case active = "active"
    case disabled = "disabled"
    
    init(status: String) {
        self.init(rawValue: status)!
    }
    
    var stringValue: String {
        return rawValue
    }
}

final class App {
    
    var id: Int?
    
    var name: String
    var location: String
    var vendorId: Int
    var status: AppStatus
    
    init(id: Int? = nil, name: String, location: String, vendorId: Int, status: String) {
        self.id = id
        self.name = name
        self.location = location
        self.vendorId = vendorId
        self.status = AppStatus(status: status)
    }
    
    init(with dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as! String
        self.location = dictionary["location"] as! String
        self.vendorId = dictionary["vendor_id"] as! Int
        self.status = AppStatus(status: dictionary["status"] as! String)
    }
}

// MARK: - Entity

extension App: Entity {
    static let entity: String = "apps"
}

// MARK: - Response

extension App {
    var responseDictionary: [String: Any] {
        var result: [String: Any] = [
            "name": name,
            "location": location,
            "vendorId": vendorId,
            "status": status.stringValue
        ]
        if let id = id {
            result["id"] = id
        }
        return result
    }
}



