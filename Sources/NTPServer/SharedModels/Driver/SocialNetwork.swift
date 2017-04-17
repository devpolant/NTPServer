//
//  SocialNetwork.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 31.03.17.
//
//

import Foundation

enum SocialNetwork: Int {
    case vk = 1
    
    init(identifier: Int) {
        self.init(rawValue: identifier)!
    }
    
    var identifier: Int {
        return rawValue
    }
}
