//
//  DBVendorProvider.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

import MySQL

class DBVendorProvider {
    
    static let shared = DBVendorProvider()
    private init() {}
    
    
    // MARK: - Vendors
    
    // MARK: Save
    
    /// Returns id of created user
    @discardableResult
    func insertVendor(_ vendor: Vendor, to database: Database, on connection: Connection) throws -> Int {
        
        let insertQuery = "INSERT INTO `\(Vendor.entity)` (login, email, password, salt, token) VALUES (?, ?, ?, ?, ?);"
        let arguments = [vendor.login, vendor.email, vendor.password, vendor.salt, vendor.token]
        // Insert
        try database.execute(insertQuery, arguments, connection)
        // Fetch inserted id
        return try fetchVendor(withLogin: vendor.login, from: database, on: connection).id!
    }
    
    func updateVendor(_ vendor: Vendor, in database: Database, on connection: Connection) throws {
        guard let vendorId = vendor.id else {
            throw DBError.identifierAbsent(entityName: Vendor.entity)
        }
        let updateQuery = "UPDATE `\(Vendor.entity)` SET `login` = ? AND `email` = ? AND `salt` = ?, `password` = ? AND `token` = ? WHERE `id` = ?"
        let arguments: [NodeRepresentable] = [vendor.login, vendor.email, vendor.salt, vendor.password, vendor.token, vendorId]
        try database.execute(updateQuery, arguments, connection)
    }
 
    // MARK: Fetch
    
    func fetchVendor(withLogin login: String, from database: Database, on connection: Connection) throws -> Vendor {
        
        let query = "SELECT * FROM `\(Vendor.entity)` WHERE `login` = ?;"
        let arguments: [NodeRepresentable] = [login]
        
        let vendors = try database.execute(query, arguments, connection)
        guard let vendorNode = vendors.first else {
            throw DBError.entityNotFound(entityName: Vendor.entity)
        }
        return Vendor(with: vendorNode)
    }
    
    func fetchVendor(withEmail email: String, from database: Database, on connection: Connection) throws -> Vendor {
        
        let query = "SELECT * FROM `\(Vendor.entity)` WHERE `email` = ?;"
        let arguments: [NodeRepresentable] = [email]
        
        let vendors = try database.execute(query, arguments, connection)
        guard let vendorNode = vendors.first else {
            throw DBError.entityNotFound(entityName: Vendor.entity)
        }
        return Vendor(with: vendorNode)
    }
    
    func fetchVendor(withToken token: String, from database: Database, on connection: Connection) throws -> Vendor {
        
        let query = "SELECT * FROM `\(Vendor.entity)` WHERE `token` = ?;"
        let arguments: [NodeRepresentable] = [token]
        
        let vendors = try database.execute(query, arguments, connection)
        guard let vendorNode = vendors.first else {
            throw DBError.entityNotFound(entityName: Vendor.entity)
        }
        return Vendor(with: vendorNode)
    }
    
    
    // MARK: - Tokens
    
    func token(forVendorWithId vendorId: Int, from database: Database, on connection: Connection) throws -> String? {
        
        let findQuery = "SELECT `token` FROM `\(Vendor.entity)` WHERE id = ?"
        let arguments: [NodeRepresentable] = [vendorId]
        
        let vendorTokens = try database.execute(findQuery, arguments, connection)
        guard let token = vendorTokens.first else {
            throw DBError.vendorTokenNotFound
        }
        return token["token"]?.string
    }
    
    
    // MARK: - Apps
    
    func apps(forVendorWithId vendorId: Int, from database: Database, on connection: Connection) throws -> [App] {
        let query = "SELECT * FROM `\(App.entity)` WHERE `vendor_id` = ?;"
        let arguments: [NodeRepresentable] = [vendorId]
        
        let apps = try database.execute(query, arguments, connection)
        return apps.map { App(with: $0) }
    }
    
    func app(with appId: Int, from database: Database, on connection: Connection) throws -> App {
        let query = "SELECT * FROM `\(App.entity)` WHERE `id` = ?;"
        let arguments: [NodeRepresentable] = [appId]
        
        let apps = try database.execute(query, arguments, connection)
        guard let appNode = apps.first else {
            throw DBError.appNotFound
        }
        return App(with: appNode)
    }
    
    fileprivate func app(vendorId: Int, appName: String, from database: Database, on connection: Connection) throws -> App {
        let query = "SELECT * FROM `\(App.entity)` WHERE `vendor_id` = ? AND `name` = ?;"
        let arguments: [NodeRepresentable] = [vendorId, appName]
        
        let apps = try database.execute(query, arguments, connection)
        guard let appNode = apps.first else {
            throw DBError.appNotFound
        }
        return App(with: appNode)
    }
    
    func insertApp(_ app: App, to database: Database, on connection: Connection) throws -> Int {
        let insertQuery = "INSERT INTO `\(App.entity)` (name, location, vendor_id, status) VALUES (?, ?, ?, ?);"
        let arguments: [NodeRepresentable] = [app.name, app.location, app.vendorId, app.status.stringValue]
        // Insert
        try database.execute(insertQuery, arguments, connection)
        // Fetch inserted id
        return try self.app(vendorId: app.vendorId, appName: app.name, from: database, on: connection).id!
    }
    
    func updateApp(_ app: App, to database: Database, on connection: Connection) throws {
        guard let appId = app.id else {
            throw DBError.identifierAbsent(entityName: App.entity)
        }
        let insertQuery = "UPDATE `\(App.entity)` SET `name` = ? AND `location` = ? AND `vendor_id` = ? AND `status` = ? WHERE `id` = ?"
        let arguments: [NodeRepresentable] = [app.name, app.location, app.vendorId, app.status.stringValue, appId]
        try database.execute(insertQuery, arguments, connection)
    }
    
    func deleteApp(with id: Int, from database: Database, on connection: Connection) throws {
        let deleteQuery = "DELETE FROM `\(App.entity)` WHERE `id` = ?"
        let arguments: [NodeRepresentable] = [id]
        try database.execute(deleteQuery, arguments, connection)
    }
    
}
