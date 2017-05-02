//
//  Driver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

typealias AuthCompletion = (Result<OAuthToken>) -> Void
typealias PostsCompletion = (Result<[SocialPost]>) -> Void

typealias SocialCategory = Category
typealias SocialPost = Post

enum AuthError {
    case invalidCredentials
    case internalError
}

enum Result<Value> {
    case success(value: Value)
    case error(AuthError)
}

protocol SocialDriver {
    
    func auth(with credentials: OAuthCredentials, completion: AuthCompletion)
    
    func loadPosts(for category: SocialCategory,
                   wallFilter: VKWallService.WallFilter,
                   offset: Int,
                   count: Int,
                   token: String,
                   completion: PostsCompletion)
}
