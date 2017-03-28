//
//  BackEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura
import SwiftyJSON

class BackEnd {
    
    lazy var router: Router = {
        
        let router = Router()
        router.post("/", middleware: BodyParser())
        
        router.post("/auth", handler: self.authUser)
        
        return router
    }()
    
    let driver: SocialDriver = VKDriver()
    
    
    // MARK: - Routes
    
    func authUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
    }
}
