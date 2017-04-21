//
//  HttpController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 21.04.17.
//
//

import Foundation
import SwiftyJSON

class HttpController {
    
    let baseApiURL: URL
    
    init(baseApiURL: URL) {
        self.baseApiURL = baseApiURL
    }
    
    func get(_ path: String) -> JSON? {
        return HTTPManager.shared.get(path, relatedTo: baseApiURL)
    }
    
    func post(_ path: String, fields: [String: Any]) -> JSON? {
        return HTTPManager.shared.post(path, relatedTo: baseApiURL, fields: fields)
    }
}
