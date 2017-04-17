//
//  RouterResponse+BadRequest.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Kitura
import LoggerAPI

extension RouterResponse {

    func badRequest(message: String) -> RouterResponse {
        Log.info(message)
        let error: [String: Any] = ["error": true,
                                    "message": message]
        return status(.badRequest).send(json: error)
    }
    
    func badRequest(expected parameters: [String]) -> RouterResponse {
        
        let error: [String: Any] = ["error": true,
                                    "expected_parameters": parameters]
        return status(.badRequest).send(json: error)
    }
    
    func internalServerError(message: String) -> RouterResponse {
        Log.error(message)
        
        let error: [String: Any] = ["error": true,
                                    "message": message]
        return status(.internalServerError).send(json: error)
    }
}
