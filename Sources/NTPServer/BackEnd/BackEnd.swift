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
import Cryptor
import LoggerAPI


class BackEnd {
    
    lazy var router: Router = {
        
        let router = Router()
        router.post("/", middleware: BodyParser())
        
        let mobileController = MobileAPIController()
        router.all("/mobile", middleware: mobileController.router)
        
        let webController = WebAPIController()
        router.all("/web", middleware: webController.router)
        
        return router
    }()
}
