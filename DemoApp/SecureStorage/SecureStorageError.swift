//
//  SecureStorageError.swift
//  SecureStorage
//
//  Created by Adarsh Kumar Rai on 25/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation


public enum SecureStorageError: Int, CustomNSError {
    case initializationFailed
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case keychainItemNotFound
    case keychainReadFailed
    case keychainWriteFailed
    case fileWritingFailed
    
    
    public static var errorDomain: String {
        return Constants.ErrorDomain.SecureStorage
    }
    
    public var errorCode: Int {
        return rawValue
    }
    
    public var errorUserInfo: [String : Any] {
        return ["":""]
    }
}
