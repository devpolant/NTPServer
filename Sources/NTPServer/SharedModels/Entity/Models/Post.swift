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
    var photoUrl: String?
    
    init(id: String, timestamp: Int, text: String, photoUrl: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.photoUrl = photoUrl
    }
}

// MARK: - Entity

extension Post: Entity {
    static let entity: String = "posts"
}

// MARK: - JSON Convertation

extension Post {
    
    var dictionaryValue: [String: Any] {
        var result: [String: Any] = [
            "id": id,
            "date": timestamp,
            "text": text
        ]
        if let photo = photoUrl {
            result["photo_url"] = photo
        }
        return result
    }
}
