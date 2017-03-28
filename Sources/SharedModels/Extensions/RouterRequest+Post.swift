//
//  RouterRequest+Post.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Kitura

extension RouterRequest {
    
    func getPost(fields: [String]) -> [String: String]? {
        
        // make sure we have some values to parse
        guard let values = self.body else { return nil }
        
        let removeHTMLEncoding: Bool
        let submittedFields: [String: String]
        
        switch values {
        case .urlEncoded(let body):
            submittedFields = body
            removeHTMLEncoding = true
        case .json(let body):
            guard let unwrapped = body.dictionaryObject as? [String: String] else {
                return nil
            }
            submittedFields = unwrapped
            removeHTMLEncoding = false
        default:
            return nil
        }
        
        // prepare our list of finished fields
        var result = [String: String]()
        
        for field in fields {
            
            if let value = submittedFields[field]?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if value.characters.count > 0 {
                    
                    if removeHTMLEncoding {
                        result[field] = value.removingHTMLEncoding()
                    } else {
                        result[field] = value
                    }
                    continue
                }
            }
            return nil
        }
        return result
    }
}
