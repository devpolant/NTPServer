//
//  Credentials.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//


/// Credentials which needed to authorize user 
/// and used to get access token to continue work with application.
struct OAuthCredentials {
    /// Value of code, which needed to get access token.
    var code: String
}
