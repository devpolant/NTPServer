//
//  AuthResult.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

enum AuthResult {
    case success(token: AccessToken)
    case error(AuthError)
}
