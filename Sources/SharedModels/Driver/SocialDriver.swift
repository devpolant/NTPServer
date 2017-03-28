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

protocol SocialDriver {
    func auth(with credentials: InitialCredentials, completion: AuthCompletion)
    func loadPosts(for group: SocialGroup, offset: Int, count: Int, completion: PostsCompletion)
}
