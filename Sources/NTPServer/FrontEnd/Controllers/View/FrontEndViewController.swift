//
//  FrontEndViewController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 21.04.17.
//
//

import Foundation
import Kitura

class FrontEndViewController {
    
    let templateFolder: String
    
    init(templateFolder: String) {
        self.templateFolder = templateFolder
    }
    
    // MARK: - Main
    
    func getMainPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/index", context: [:])
    }
    
    // MARK: - Sign Up
    
    func getSignUpPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/signup", context: [:])
    }
 
    // MARK: - Profile
    
    func getProfilePage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/user_profile", context: [:])
    }
    
    // MARK: - Dashboard
    
    func getDashboardPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/dashboard", context: [:])
    }
    
    // MARK: Apps
    
    func getCreateAppPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/create_app", context: [:])
    }
    
    func getSelectedAppPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        guard let appId = request.parameters["id"]?.int else {
            try response.badRequest(expected: ["id"]).end()
            return
        }
 
        let context = [
            "app_id": appId
        ]
        try response.render("\(templateFolder)/selected_app", context: context)
    }
    
}
