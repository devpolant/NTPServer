//
//  Post.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 01.04.17.
//
//

import Foundation

final class Post {
    var id: String
    var timestamp: Int
    var text: String
    
    init(id: String, timestamp: Int, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }
}

// MARK: - Entity

extension Post: Entity {
    static let entity: String = "posts"
}

// MARK: - JSON Convertation

extension Post {
    
    var dictionaryValue: [String: Any] {
        return [
            "id": id,
            "date": timestamp,
            "text": text
        ]
    }
}
