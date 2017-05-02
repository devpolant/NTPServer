//
//  Category.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

final class Category {
    
    struct Filter {
        var query: String
    }
    
    var id: Int?
    
    var name: String
    var appId: Int
    var socialGroupURL: String
    var socialNetwork: SocialNetwork
    
    var domain: String {
        return URL(string: socialGroupURL)!.lastPathComponent
    }
    
    var filter: Filter?
    var hasFilter: Bool {
        return filter != nil
    }
    
    init(id: Int? = nil, name: String, appId: Int, socialGroupURL: String, socialNetworkId: Int, filter: Filter?) {
        self.id = id
        self.name = name
        self.appId = appId
        self.socialGroupURL = socialGroupURL
        self.socialNetwork = SocialNetwork(identifier: socialNetworkId)
        self.filter = filter
    }
    
    init(with dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as! String
        self.appId = dictionary["app_id"] as! Int
        self.socialGroupURL = dictionary["social_group"] as! String
        self.socialNetwork = SocialNetwork(identifier: dictionary["social_network_id"] as! Int)
        let filterQuery = dictionary["filter_query"] as? String
        if let query = filterQuery {
            self.filter = Filter(query: query)
        }
    }
}

// MARK: - Entity

extension Category: Entity {
    static let entity: String = "categories"
}

// MARK: - Response

extension Category {
    var responseDictionary: [String: Any] {
        var result: [String: Any] = [
            "name": name,
            "app_id": appId,
            "social_group": socialGroupURL,
            "social_network_id": socialNetwork.identifier
        ]
        if let id = id {
            result["id"] = id
        }
        if let filter = filter {
            result["filter_query"] = filter.query
        }
        return result
    }
}

