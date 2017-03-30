//
//  CryptoManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Cryptor

class CryptoManager {
    
    static let shared = CryptoManager()
    
    private init() {}
    
    func password(from string: String, salt: String) -> String {
        
        let key = PBKDF.deriveKey(fromPassword: string,
                                  salt: salt,
                                  prf: .sha512,
                                  rounds: 250_000,
                                  derivedKeyLength: 64)
        
        return CryptoUtils.hexString(from: key)
    }
}
