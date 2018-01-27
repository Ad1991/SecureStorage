//
//  SecureStorage.swift
//  SecureStorage
//
//  Created by Adarsh Kumar Rai on 27/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation

@objc public final class SecureStorage: NSObject {
    
    var storageType: SSStorageType
    var keychainHandler: KeychainHandler
    let storageLocation: Any
    
    
    public init(keychainAccessGroup: String?, keychainAccessControl: CFString) {
        self.storageType = .defaults
        self.storageLocation = UserDefaults.standard
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
    public init(fileLocation: String, keychainAccessGroup: String?, keychainAccessControl: CFString) throws {
        var isDirectory = ObjCBool(false)
        let fileExists = FileManager.default.fileExists(atPath: fileLocation, isDirectory: UnsafeMutablePointer(&isDirectory))
        if !fileExists || !isDirectory.boolValue {
            throw SecureStorageError.initializationFailed
        }
        self.storageType = .file
        self.storageLocation = URL(fileURLWithPath: fileLocation)
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
    public init(sharedDefaultsId: String, keychainAccessGroup: String?, keychainAccessControl: CFString) throws {
        self.storageType = .sharedDefaults
        if let sharedDefaults = UserDefaults.init(suiteName: sharedDefaultsId) {
            self.storageLocation = sharedDefaults
        } else {
            throw SecureStorageError.initializationFailed
        }
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
}
