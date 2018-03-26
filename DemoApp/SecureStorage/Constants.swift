//
//  Constants.swift
//  SecureStorage
//
//  Created by Adarsh Kumar Rai on 27/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation

public enum SSStorageType {
    case defaults (UserDefaults)
    case sharedDefaults (UserDefaults)
    case file (URL)
}


struct Constants {
    
    struct Keychain {
        static let defaultAccountName: String = "keychainUserAccoutName"
        static let secureKeyIdentifier: String = "com.personal.securestorage.securekey"
    }
    
    struct ErrorDomain {
        static let SecureStorage: String = "SecureStorageDomain"
    }
}
