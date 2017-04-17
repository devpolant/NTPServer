//
//  FrontEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura
import KituraTemplateEngine
import KituraStencil
import KituraNet
import KituraCORS
import SwiftyJSON

class FrontEnd {
    
    let baseApiURL = URL(string: "http://localhost:8089")!
    
    lazy var router: Router = {
        
        let router = Router()
        
        // File Server
        router.all("/static", middleware: StaticFileServer())
        // Parser
        router.post("/", middleware: BodyParser())
        // Templates
        router.setDefault(templateEngine: self.defaultTemplateEngine())
        // CORS
        router.all(middleware: self.corsMiddleware())
        
        // API
        let apiController = FrontEndAPIController(baseApiURL: self.baseApiURL, templateFolder: self.templateFolder)
        router.all(middleware: apiController.router)
        
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

// MARK: - Templates

extension FrontEnd {
    
    var templateFolder: String {
        return "/stencil"
    }
    
    fileprivate func defaultTemplateEngine() -> TemplateEngine {
        return StencilTemplateEngine()
    }
}


// MARK: - CORS

extension FrontEnd {
    
    fileprivate func corsMiddleware() -> RouterMiddleware {
        
        let allowedHeaders = [
            "Content-Type",
            "X-Requested-With",
            "Origin",
            "Accept",
            "Access-Control-Allow-Origin",
            "Authorization"
        ]
        
        let httpMethods = [
            HTTPMethod.get.stringValue,
            HTTPMethod.head.stringValue,
            HTTPMethod.post.stringValue,
            HTTPMethod.put.stringValue,
            HTTPMethod.delete.stringValue,
            HTTPMethod.connect.stringValue,
            HTTPMethod.options.stringValue,
            HTTPMethod.trace.stringValue
        ]
        
        let options = Options(allowedOrigin: .all,
                              methods: httpMethods,
                              allowedHeaders: allowedHeaders)
        
        return CORS(options: options)
    }
}
