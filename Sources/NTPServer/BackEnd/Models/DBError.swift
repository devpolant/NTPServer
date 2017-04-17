//
//  DBError.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

enum DBError: Swift.Error {
    case couldNotSave
    case entityNotFound(entityName: String)
    case identifierAbsent(entityName: String)
    case tokenNotFound(destination: TokenDestination)
    case vendorTokenNotFound
    case appNotFound
    case categoryNotFound
}
