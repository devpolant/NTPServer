//
//  SocialNetwork.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 31.03.17.
//
//

import Foundation

enum SocialNetwork {
    case vk
    
    var identifier: Int {
        switch self {
        case .vk:
            return 1
        }
    }
}
