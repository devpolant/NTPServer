//
//  BackEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura

class BackEnd {
    
    lazy var router: Router = {
        
        let router = Router()
        router.post("/", middleware: self.defaultParser)
        
        router.all("/mobile", middleware: self.mobileAPI.router)
        router.all("/web", middleware: self.webAPI.router)
        router.all("/iot", middleware: self.iotAPI.router)
        
        return router
    }()
}

// MARK: - Parser

extension BackEnd {
    var defaultParser: RouterMiddleware {
        return BodyParser()
    }
}

// MARK: - API

extension BackEnd {
    var mobileAPI: APIRouter {
        return MobileAPIController()
    }
    
    var webAPI: APIRouter {
        return WebAPIController()
    }
    
    var iotAPI: APIRouter {
        return IoTAPIController()
    }
}
