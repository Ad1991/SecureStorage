//
//  KeychainHandler.swift
//  SecureStorage
//
//  Created by Adarsh Kumar Rai on 27/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation


class KeychainHandler {
    
    private let accountName: String
    private let accessGroup : String?
    private let accessControlType: CFString
    
    
    //MARK:- Public Methods -
    required public init(accountName: String?, accessGroup: String?, accessControlType: CFString) {
        if let account = accountName {
            self.accountName = account
        } else {
            self.accountName = Constants.Keychain.defaultAccountName
        }
        self.accessGroup = accessGroup
        self.accessControlType = accessControlType
    }
    
    
    public func fetchObject(for key: String) throws -> Data {
        var attributeQuery = queryDictionary(for: key)
        attributeQuery[kSecReturnData as String] = kCFBooleanTrue
        var result: AnyObject?
        let status = withUnsafePointer(to: &result) {
            SecItemCopyMatching(attributeQuery as CFDictionary, UnsafeMutablePointer(mutating: $0))
        }
        if status != errSecSuccess {
            if status == errSecItemNotFound {
                throw SecureStorageError.keychainItemNotFound
            } else {
                throw SecureStorageError.keychainReadFailed
            }
        }
        if let resultData = result as? Data {
            return resultData
        } else {
            throw SecureStorageError.keychainReadFailed
        }
    }
    
    
    public func store(object: Data, for key: String) throws {
        var existingData: Data?
        do {
            existingData = try fetchObject(for: key)
        } catch SecureStorageError.keychainReadFailed {
            try? removeObject(for: key)
        }
        var status = errSecSuccess
        if let data = existingData, data != object {
            status = SecItemUpdate(queryDictionary(for: key) as CFDictionary, [kSecValueData as String: object] as CFDictionary)
        } else {
            var query = queryDictionary(for: key)
            query[kSecValueData as String] = object
            status = SecItemAdd(query as CFDictionary, nil)
        }
        if status != errSecSuccess {
            throw SecureStorageError.keychainWriteFailed
        }
    }
    
    
    public func removeObject(for key: String) throws {
        let status = SecItemDelete(queryDictionary(for: key) as CFDictionary)
        if status != errSecSuccess {
            throw SecureStorageError.keychainWriteFailed
        }
    }
    
    
    //MARK:- Private Methods -
    func queryDictionary(for key: String) -> Dictionary<String, Any> {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String : self.accountName,
            kSecAttrService as String : key,
            kSecAttrAccessible as String: self.accessControlType
        ]
        if let accessGroup = self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }
    
}
