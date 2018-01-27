//
//  SecureStorageError.swift
//  SecureStorage
//
//  Created by Adarsh Kumar Rai on 25/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation


public enum SecureStorageError: CustomNSError {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case keychainItemNotFound
    case keychainReadFailed
    case keychainWriteFailed
    
    
    public var errorCode: Int {
        return 10
    }
    
    public var errorUserInfo: [String : Any] {
        return ["":""]
    }
}
