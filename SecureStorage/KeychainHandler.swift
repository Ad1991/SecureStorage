//  The MIT License (MIT)
//
//  Copyright (c) 2018 Adarsh Rai <adrai75@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation


class KeychainHandler {
    
    private let accountName: String
    private let accessGroup : String?
    private let accessControlType: CFString
    
    
    //MARK:- Initializers -
    required public init(accountName: String = Constants.Keychain.defaultAccountName, accessGroup: String?, accessControlType: CFString) {
        self.accountName = accountName
        self.accessGroup = accessGroup
        self.accessControlType = accessControlType
    }
    
    
    //MARK:- Public Methods -
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
        } catch let error as SecureStorageError where error == .keychainReadFailed || error == .keychainItemNotFound  {
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
