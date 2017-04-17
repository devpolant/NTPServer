//
//  FrontEndViewController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation
import Kitura
import SwiftyJSON
import Cryptor
import LoggerAPI

class FrontEndAPIController: APIController {
    
    lazy var router: Router = {
        
        let router = Router()
        
        
        
        return router
    }()
    
    
    // MARK: - Routes
    
    func signUpUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        
    }
    
}
