//
//  HTTPManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import KituraNet
import SwiftyJSON

class HTTPManager {
    
    static let shared = HTTPManager()
    
    private init() {}
    
    // MARK: - HTTP Fetching
    
    func get(_ path: String, relatedTo baseURL: URL, parameters: [String: Any] = [:]) -> JSON? {
        
        var requestPath = path
        if !requestPath.isEmpty {
            requestPath.append("?")
            for (key, value) in parameters {
                requestPath.append("\(key)=\(value)&")
            }
            requestPath = String(requestPath.characters.dropLast(1))
        }
        return fetch(requestPath, relatedTo: baseURL, method: .get, body: "")
    }
    
    func post(_ path: String, relatedTo baseURL: URL, fields: [String: Any]) -> JSON? {
        let string = JSON(fields).rawString() ?? ""
        return fetch(path, relatedTo: baseURL, method: .post, body: string)
    }
    
    func fetch(_ path: String, relatedTo baseURL: URL, method: HTTPMethod, body requestBody: String) -> JSON? {
        
        guard let scheme = baseURL.scheme, let host = baseURL.host else {
            return nil
        }
        
        var requestOptions: [ClientRequest.Options] = []
        
        requestOptions.append(.schema("\(scheme)"))
        requestOptions.append(.hostname("\(host)"))
        
        if let portNumber = baseURL.port {
            let port = Int16(portNumber)
            requestOptions.append(.port(port))
        }
        requestOptions.append(.method("\(method.stringValue)"))
        requestOptions.append(.path("\(path)"))
        
        let headers = ["Content-Type": "application/json"]
        requestOptions.append(.headers(headers))
        
        var responseBody = Data()
        
        let request = HTTP.request(requestOptions) { clientResponse in
            if let response = clientResponse {
                _ = try? response.readAllData(into: &responseBody)
            }
        }
        
        // Send the request
        request.end(requestBody)
        
        if !responseBody.isEmpty {
            return JSON(data: responseBody)
        }
        return nil
    }
}
