//
//  Driver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

typealias AuthCompletion = (AuthResult<OAuthToken>) -> Void
typealias PostsCompletion = ([SocialPost]) -> Void

typealias SocialGroup = String
typealias SocialPost = String

enum AuthError {
    case invalidCredentials
    case internalError
}

enum AuthResult <T> {
    case success(token: T)
    case error(AuthError)
}

protocol SocialDriver {
    func auth(with credentials: OAuthCredentials, completion: AuthCompletion)
    func loadPosts(for group: SocialGroup, offset: Int, count: Int, completion: PostsCompletion)
}
