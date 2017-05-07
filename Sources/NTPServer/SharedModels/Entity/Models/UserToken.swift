//
//  UserToken.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

final class UserToken: Entity {
    static let entity: String = "user_tokens"
    static var primaryKey: String = "id"
    static var databaseFields: [String] = [
        
    ]
}
