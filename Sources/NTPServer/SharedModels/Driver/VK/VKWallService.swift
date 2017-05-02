//
//  VKWallService.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 02.05.17.
//
//

import Foundation
import SwiftyJSON

class VKWallService {
    
    static let shared = VKWallService()
    private init() {}
    
    // MARK: Method
    
    struct Method {
        static let get = "/method/wall.get"
        static let search = "/method/wall.search"
    }
    
    // MARK: WallFilter
    
    struct WallFilter: OptionSet {
        let rawValue: Int
        
        static let owner = WallFilter(rawValue: 1 << 0)
        static let all = WallFilter(rawValue: 1 << 31)
    }
    
    private struct WallRequest {
        let category: Category
        let token: String
        let offset: Int
        let count: Int
        let wallFilter: WallFilter
        
        var path: String {
            if category.hasFilter {
                return Method.search
            } else {
                return Method.get
            }
        }
        
        var parameters: [String: Any] {
            var result: [String: Any] = [
                "domain": category.domain,
                "offset": offset,
                "count": count,
                "extended": true,
                "access_token": token,
                "v": VK.API.version
            ]
            if category.hasFilter {
                result["query"] = category.filter!.query
            }
            if wallFilter == .owner {
                if category.hasFilter {
                    result["owners_only"] = true
                } else {
                    result["filter"] = "owner"
                }
            }
            return result
        }
    }
    
    func wall(for category: SocialCategory, wallFilter: WallFilter, token: String, offset: Int, count: Int) -> Result<JSON> {
        
        let request = WallRequest(category: category, token: token, offset: offset, count: count, wallFilter: wallFilter)
        let json = HTTPManager.shared.get(request.path, relatedTo: VK.API.baseURL, parameters: request.parameters)
        
        guard let jsonObject = json else {
            return .error(AuthError.internalError)
        }
        return .success(value: jsonObject)
    }
}
