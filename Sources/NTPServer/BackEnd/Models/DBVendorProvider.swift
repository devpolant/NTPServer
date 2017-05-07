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
        let updateQuery = "UPDATE `\(Vendor.entity)` SET `login` = ?, `email` = ?, `salt` = ?, `password` = ?, `token` = ? WHERE `id` = ?;"
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
        
        let findQuery = "SELECT `token` FROM `\(Vendor.entity)` WHERE id = ?;"
        let arguments: [NodeRepresentable] = [vendorId]
        
        let vendorTokens = try database.execute(findQuery, arguments, connection)
        guard let token = vendorTokens.first else {
            throw DBError.vendorTokenNotFound
        }
        return token["token"]?.string
    }
    
    
    // MARK: - Apps
    
    // MARK: Save
    
    @discardableResult
    func insertApp(_ app: App, to database: Database, on connection: Connection) throws -> Int {
        let insertQuery = "INSERT INTO `\(App.entity)` (name, location, vendor_id, status) VALUES (?, ?, ?, ?);"
        let arguments: [NodeRepresentable] = [app.name, app.location, app.vendorId, app.status.stringValue]
        // Insert
        try database.execute(insertQuery, arguments, connection)
        // Fetch inserted id
        return try self.fetchApp(vendorId: app.vendorId, appName: app.name, from: database, on: connection).id!
    }
    
    func updateApp(_ app: App, in database: Database, on connection: Connection) throws {
        guard let appId = app.id else {
            throw DBError.identifierAbsent(entityName: App.entity)
        }
        let updateQuery = "UPDATE `\(App.entity)` SET `name` = ?, `location` = ?, `vendor_id` = ?, `status` = ? WHERE `id` = ?;"
        let arguments: [NodeRepresentable] = [app.name, app.location, app.vendorId, app.status.stringValue, appId]
        try database.execute(updateQuery, arguments, connection)
    }
    
    func deleteApp(with id: Int, from database: Database, on connection: Connection) throws {
        
        // TODO: handle errors
        try deleteCategories(forApp: id, from: database, on: connection)
        
        let deleteAppQuery = "DELETE FROM `\(App.entity)` WHERE `id` = ?;"
        let deleteAppArguments: [NodeRepresentable] = [id]
        try database.execute(deleteAppQuery, deleteAppArguments, connection)
    }
    
    // MARK: Fetch
    
    func fetchApps(forVendorWithId vendorId: Int, from database: Database, on connection: Connection) throws -> [App] {
        let query = "SELECT a.*, c.social_group FROM `\(App.entity)` a, `\(Category.entity)` c WHERE c.app_id = a.id AND  a.vendor_id = ?;"
        let arguments: [NodeRepresentable] = [vendorId]
        
        var uniqueAppIds = [String: Any]()
        
        let apps = try database.execute(query, arguments, connection)
        return apps.flatMap { json in
            let appId = json[App.primaryKey]!.string!
            guard uniqueAppIds[appId] == nil else {
                return nil
            }
            uniqueAppIds[appId] = true
            return App(with: json)
        }
    }
    
    func fetchApp(with appId: Int, from database: Database, on connection: Connection) throws -> App {
        let query = "SELECT a.*, c.social_group FROM `\(App.entity)` a, `\(Category.entity)` c WHERE c.app_id = a.id AND a.id = ?;"
        let arguments: [NodeRepresentable] = [appId]
        
        let apps = try database.execute(query, arguments, connection)
        guard let appNode = apps.first else {
            throw DBError.appNotFound
        }
        return App(with: appNode)
    }
    
    fileprivate func fetchApp(vendorId: Int, appName: String, from database: Database, on connection: Connection) throws -> App {
        let query = "SELECT * FROM `\(App.entity)` WHERE vendor_id = ? AND name = ?;"
        let arguments: [NodeRepresentable] = [vendorId, appName]
        
        let apps = try database.execute(query, arguments, connection)
        guard let appNode = apps.first else {
            throw DBError.appNotFound
        }
        return App(with: appNode)
    }
    
    
    // MARK: - Category
    
    // MARK: Save
    
    @discardableResult
    func insertCategory(_ category: Category, to database: Database, on connection: Connection) throws -> Int {
        
        var fields = ["name", "app_id", "social_group", "social_network_id"]
        var arguments: [NodeRepresentable] = [
            category.name, category.appId, category.socialGroupURL, category.socialNetwork.identifier
        ]
        
        if let filter = category.filter {
            arguments.append(filter.query)
            fields.append("filter_query")
        }
        
        let sqlColumns = fields.joined(separator: ",")
        let sqlValues = Array(repeating: "?", count: fields.count).joined(separator: ",")
        
        let insertQuery = "INSERT INTO `\(Category.entity)` (\(sqlColumns)) VALUES (\(sqlValues));"
        print(insertQuery)
        // Insert
        try database.execute(insertQuery, arguments, connection)
        // Fetch inserted id
        return try self.firstCategory(forApp: category.appId, from: database, on: connection).id!
    }
    
    func updateCategory(_ category: Category, in database: Database, on connection: Connection) throws {
        // TODO: update filter_query
        guard let categoryId = category.id else {
            throw DBError.identifierAbsent(entityName: Category.entity)
        }
        let updateQuery = "UPDATE `\(Category.entity)` SET `name` = ?, `app_id` = ?, `social_group` = ?, `social_network_id` = ? WHERE `id` = ?;"
        let arguments: [NodeRepresentable] =
            [category.name, category.appId, category.socialGroupURL, category.socialNetwork.identifier, categoryId]
        try database.execute(updateQuery, arguments, connection)
    }
    
    func deleteCategory(with id: Int, from database: Database, on connection: Connection) throws {
        let deleteQuery = "DELETE FROM `\(Category.entity)` WHERE `id` = ?;"
        let arguments: [NodeRepresentable] = [id]
        try database.execute(deleteQuery, arguments, connection)
    }
    
    func deleteCategories(forApp appId: Int, from database: Database, on connection: Connection) throws {
        let deleteQuery = "DELETE FROM `\(Category.entity)` WHERE `app_id` = ?;"
        let arguments: [NodeRepresentable] = [appId]
        try database.execute(deleteQuery, arguments, connection)
    }
    
    // MARK: Fetch
    
    /// Temporary method
    func firstCategory(forApp appId: Int, from database: Database, on connection: Connection) throws -> Category {
        let query = "SELECT * FROM `\(Category.entity)` WHERE `app_id` = ?;"
        let arguments: [NodeRepresentable] = [appId]
        
        let categories = try database.execute(query, arguments, connection)
        guard let categoryNode = categories.first else {
            throw DBError.categoryNotFound
        }
        return Category(with: categoryNode)
    }
    
    func fetchCategory(with id: Int, from database: Database, on connection: Connection) throws -> Category {
        let query = "SELECT * FROM `\(Category.entity)` WHERE `id` = ?;"
        let arguments: [NodeRepresentable] = [id]
        
        let categories = try database.execute(query, arguments, connection)
        guard let categoryNode = categories.first else {
            throw DBError.categoryNotFound
        }
        return Category(with: categoryNode)
    }
    
    func fetchCategories(forApp appId: Int, from database: Database, on connection: Connection) throws -> [Category] {
        let query = "SELECT * FROM `\(Category.entity)` WHERE `app_id` = ?;"
        let arguments: [NodeRepresentable] = [appId]
        
        let categoriesJson = try database.execute(query, arguments, connection)
        return categoriesJson.map {
            Category(with: $0)
        }
    }
}
