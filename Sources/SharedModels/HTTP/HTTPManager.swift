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
    
    func get(_ path: String, relatedTo baseURL: URL) -> JSON? {
        return fetch(path, relatedTo: baseURL, method: .get, body: "")
    }
    
    func post(_ path: String, relatedTo baseURL: URL, fields: [String: Any]) -> JSON? {
        let string = JSON(fields).rawString() ?? ""
        return fetch(path, relatedTo: baseURL, method: .post, body: string)
    }
    
    func fetch(_ path: String, relatedTo baseURL: URL, method: HTTPMethod, body requestBody: String) -> JSON? {
        
        guard let scheme = baseURL.scheme,
            let host = baseURL.host,
            let portNumber = baseURL.port else {
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
