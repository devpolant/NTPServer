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
        router.all("/static", middleware: self.defaultFileServer)
        // Parser
        router.post("/", middleware: self.defaultParser)
        // Templates
        router.setDefault(templateEngine: self.defaultTemplateEngine)
        // CORS
        router.all(middleware: self.corsMiddleware)
        
        // Controllers
        let apiController = FrontEndAPIController(baseApiURL: self.baseApiURL)
        let viewController = FrontEndViewController(templateFolder: self.templateFolder)
        
        self.setupRoutes(for: router, api: apiController, view: viewController)
        
        return router
    }()
    
    // MARK: Routes
    
    private func setupRoutes(for router: Router, api: FrontEndAPIController, view: FrontEndViewController) {
        
        router.get("/", handler: view.getMainPage)
        
        let authRouter = router.route("/auth")
        
        authRouter.post("/login", handler: api.login)
        authRouter.route("/signup")
            .get(handler: view.getSignUpPage)
            .post(handler: api.signUp)
        
        router.get("/profile", handler: view.getProfilePage)
        
        let dashboardRouter = router.route("/dashboard")
        dashboardRouter.get(handler: view.getDashboardPage)
        
        dashboardRouter.route("/apps")
            .get("/create", handler: view.getCreateAppPage)
            .get("/:id/info", handler: view.getSelectedAppPage)
    }
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

// MARK: - Files

extension FrontEnd {
    
    fileprivate var defaultFileServer: RouterMiddleware {
        return StaticFileServer()
    }
}

// MARK: - Parser

extension FrontEnd {
    
    fileprivate var defaultParser: RouterMiddleware {
        return BodyParser()
    }
}

// MARK: - Templates

extension FrontEnd {
    
    var templateFolder: String {
        return "/stencil"
    }
    
    fileprivate var defaultTemplateEngine: TemplateEngine {
        return StencilTemplateEngine()
    }
}

// MARK: - CORS

extension FrontEnd {
    
    fileprivate var corsMiddleware: RouterMiddleware {
        
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
