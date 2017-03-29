//
//  String+HTMLEncoding.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

extension String {
    func removingHTMLEncoding() -> String {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding ?? result
    }
}
