//
//  VKAPI.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 01.05.17.
//
//

import Foundation

struct VK {
    
    struct API {
        static let baseURL = URL(string: "https://api.vk.com")!
        static let version = "5.63"
    }
    
    struct App {
        
        let clientId: String
        let clientSecret: String
        let redirectURI: String
        
        static let current = App(clientId: "5948504",
                                 clientSecret: "P4ThWqsQhMcM2wkMjW6y",
                                 redirectURI: "http://localhost:8090/auth_vk_callback")
        
        init(clientId: String, clientSecret: String, redirectURI: String) {
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.redirectURI = redirectURI
        }
    }
}
