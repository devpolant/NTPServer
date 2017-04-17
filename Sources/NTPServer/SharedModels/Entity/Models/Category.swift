//
//  Category.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

final class Category {
    var id: Int?
    
    var name: String
    var appId: Int
    var socialGroupURL: String
    var socialNetwork: SocialNetwork
    
    init(id: Int? = nil, name: String, appId: Int, socialGroupURL: String, socialNetworkId: Int) {
        self.id = id
        self.name = name
        self.appId = appId
        self.socialGroupURL = socialGroupURL
        self.socialNetwork = SocialNetwork(identifier: socialNetworkId)
    }
    
    init(with dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as! String
        self.appId = dictionary["app_id"] as! Int
        self.socialGroupURL = dictionary["social_group"] as! String
        self.socialNetwork = SocialNetwork(identifier: dictionary["social_network_id"] as! Int)
    }
}

// MARK: - Entity

extension Category: Entity {
    static let entity: String = "categories"
}
