//
//  DBConnector.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import MySQL

class MySQLConnector {
    
    static func connectToDatabase() throws -> (Database, Connection) {
        let mysql = try Database(
            host: "localhost",
            user: "db_username",
            password: "db_password",
            database: "db_name"
        )
        let connection = try mysql.makeConnection()
        return (mysql, connection)
    }
}

