//
//  Entity.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

protocol Entity {
    static var entity: String { get }
    static var primaryKey: String { get }
    static var databaseFields: [String] { get }
}



