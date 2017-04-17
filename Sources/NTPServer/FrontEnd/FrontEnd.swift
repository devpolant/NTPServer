//
//  FrontEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura
import KituraNet
import SwiftyJSON

class FrontEnd {
    
    let baseApiURL = URL(string: "http://localhost:8089")!
    
    lazy var router: Router = {
        
        let router = Router()
    
        // Routes here
        
        return router
    }()
}


// MARK: - HTTP Fetching
extension FrontEnd {
    
    func get(_ path: String) -> JSON? {
        return HTTPManager.shared.get(path, relatedTo: baseApiURL)
    }
    
    func post(_ path: String, fields: [String: Any]) -> JSON? {
        return HTTPManager.shared.post(path, relatedTo: baseApiURL, fields: fields)
    }
}
