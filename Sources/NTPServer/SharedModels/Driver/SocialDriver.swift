//
//  Driver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

typealias AuthCompletion = (AuthResult) -> Void
typealias PostsCompletion = ([SocialPost]) -> Void

typealias SocialGroup = String
typealias SocialPost = String

enum AuthError {
    case invalidCredentials
    case internalError
}

protocol SocialDriver {
    func auth(with credentials: OAuthCredentials, completion: AuthCompletion)
    func loadPosts(for group: SocialGroup, offset: Int, count: Int, completion: PostsCompletion)
}
