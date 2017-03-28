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
        
        guard let fields = request.getPost(fields: ["code"]) else {
            return
        }
        let code = fields["code"]!
        let inputCredentials = InitialCredentials(stringValue: code)
        
        var json: JSON?
        driver.auth(with: inputCredentials) { result in
            switch result {
            case .success(let token):
                json = JSON(["access_token": token,
                             "userId": token.userId ?? ""])
            case .error( _):
                break
            }
        }
        response.send(json: json!)
    }
}
