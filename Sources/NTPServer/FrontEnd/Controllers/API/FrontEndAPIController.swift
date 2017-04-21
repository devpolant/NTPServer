//
//  FrontEndViewController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation
import Kitura
import KituraTemplateEngine
import KituraCORS
import SwiftyJSON
import Cryptor
import LoggerAPI

class FrontEndAPIController {

    /// Data Layer server url
    let baseApiURL: URL
    
    init(baseApiURL: URL) {
        self.baseApiURL = baseApiURL
    }
    
    // MARK: - Auth
    
    // MARK: Login
    
    func login(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        let requiredFields = ["email", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        guard let loginResult = HTTPManager.shared.post("/web/vendor/auth/login",
                                                         relatedTo: baseApiURL,
                                                         fields: fields) else {
                                                            return
        }
        response.send(json: loginResult)
    }
    
    // MARK: Sign Up
    
    func signUp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        
        let requiredFields = ["login", "email", "password", "confirm_password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let password = fields["password"]!
        let confirmPassword = fields["confirm_password"]!
        
        guard password == confirmPassword else {
            try response.badRequest(message: "Password doesn't match").end()
            return
        }
        
        guard let signupResult = HTTPManager.shared.post("/web/vendor/auth/signup",
                                                         relatedTo: baseApiURL,
                                                         fields: fields)?.dictionaryObject else {
                                                            return
        }
        response.send(json: signupResult)
    }

}
