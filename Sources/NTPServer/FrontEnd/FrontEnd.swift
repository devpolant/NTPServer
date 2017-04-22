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
        
        // Auth
        
        let authRouter = router.route("/auth")
        
        authRouter.route("/login")
            .post(handler: api.login)
        
        authRouter.route("/signup")
            .get(handler: view.getSignUpPage)
            .post(handler: api.signUp)
        
        // Profile
        
        let profileRouter = router.route("/profile")
        profileRouter.get(handler: view.getProfilePage)
        
        // Dashboard
        
        let dashboardRouter = router.route("/dashboard")
        dashboardRouter.get(handler: view.getDashboardPage)
        
        // Apps
        
        let appsRouter = dashboardRouter.route("/apps")
        
        appsRouter.route("/list")
            .post(handler: api.appsList)
        
//        appsRouter.route("/:id/info")
//            .get(handler: view.getSelectedAppPage)
//            .post(handler: api.appInfo)
        
        appsRouter.get("/:id/info", handler: view.getSelectedAppPage)
        appsRouter.post("/:id/info", handler: api.appInfo)
        
        appsRouter.route("/create")
            .get(handler: view.getCreateAppPage)
            .post(handler: api.createApp)
        
//        appsRouter.route("/:id/update")
//            .post(handler: api.updateApp)
        
        appsRouter.post("/:id/update", handler: api.updateApp)
        
//        appsRouter.route("/:id/delete")
//            .post(handler: api.deleteApp)
        
        appsRouter.post("/:id/delete", handler: api.deleteApp)
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
        
        let options = Options(allowedOrigin: .all,
                              methods: allowedHttpMethods,
                              allowedHeaders: allowedHeaders)
        
        return CORS(options: options)
    }
    
    private var allowedHttpMethods: [String] {
        return [
            HTTPMethod.get.stringValue,
            HTTPMethod.head.stringValue,
            HTTPMethod.post.stringValue,
            HTTPMethod.put.stringValue,
            HTTPMethod.delete.stringValue,
            HTTPMethod.connect.stringValue,
            HTTPMethod.options.stringValue,
            HTTPMethod.trace.stringValue
        ]
    }
    
    private var allowedHeaders: [String] {
        return [
            "Content-Type",
            "X-Requested-With",
            "Origin",
            "Accept",
            "Access-Control-Allow-Origin",
            "Authorization"
        ]
    }
}
