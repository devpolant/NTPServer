//
//  FrontEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura
import KituraNet
import SwiftyJSON

class FrontEnd {
    
    let baseApiURL = URL(string: "http://localhost:8089")
    
    lazy var router: Router = {
        
        let router = Router()
        
        return router
    }()
}


// MARK: - HTTP Fetching
extension FrontEnd {
    
    func get(_ path: String) -> JSON? {
        return fetch(path, method: .get, body: "")
    }
    
    func post(_ path: String, fields: [String: Any]) -> JSON? {
        let string = JSON(fields).rawString() ?? ""
        return fetch(path, method: .post, body: string)
    }
    
    func fetch(_ path: String, method: HTTPMethod, body requestBody: String) -> JSON? {
        
        guard let scheme = baseApiURL?.scheme,
            let host = baseApiURL?.host,
            let portNumber = baseApiURL?.port else {
                return nil
        }
        let port = Int16(portNumber)
        
        var requestOptions: [ClientRequest.Options] = []
        
        requestOptions.append(.schema("\(scheme)"))
        requestOptions.append(.hostname("\(host)"))
        requestOptions.append(.port(port))
        requestOptions.append(.method("\(method.stringValue)"))
        requestOptions.append(.path("\(path)"))
        
        let headers = ["Content-Type": "application/json"]
        requestOptions.append(.headers(headers))
        
        var responseBody = Data()
        
        let request = HTTP.request(requestOptions) { clientResponse in
            if let response = clientResponse {
                guard response.statusCode == .OK else { return }
                _ = try? response.readAllData(into: &responseBody)
            }
        }
        
        // Send the request
        request.end(requestBody)
        
        return !responseBody.isEmpty ? JSON(data: responseBody) : nil
    }
}
