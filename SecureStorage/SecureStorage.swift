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

@objc public final class SecureStorage: NSObject {
    
    var storageType: SSStorageType
    var keychainHandler: KeychainHandler
    
    //MARK:- Initializers -
    
    /// Initialize SecureStorage to store data in UserDefaults and keys in Keychain with provided access control.
    ///
    /// - Parameters:
    ///   - keychainAccessGroup: If provided, keys will be stored in keychain access group. Requires Keychain Sharing capability
    ///   - keychainAccessControl: Access control for the keychain item. Default value is strictest policy kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
    public init(keychainAccessGroup: String?, keychainAccessControl: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) {
        self.storageType = .defaults(UserDefaults.standard)
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
    /// Initialize SecureStorage to store data on a file location in applications sandbox. Providing right location for file storage is applications responsibility.
    ///
    /// - Parameters:
    ///   - fileLocation: Location of directory where SecureStorage should store files.
    ///   - keychainAccessGroup: If provided, keys will be stored in keychain access group. Requires Keychain Sharing capability
    ///   - keychainAccessControl: Access control for the keychain item. Default value is strictest policy kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
    /// - Throws: Throws initialization failed error if a file already exists at provided location or if the location is not a directory.
    public init(fileLocation: String, keychainAccessGroup: String?, keychainAccessControl: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) throws {
        var isDirectory = ObjCBool(false)
        let fileExists = FileManager.default.fileExists(atPath: fileLocation, isDirectory: UnsafeMutablePointer(&isDirectory))
        if !fileExists || !isDirectory.boolValue {
            throw SecureStorageError.initializationFailed
        }
        self.storageType = .file(URL(fileURLWithPath: fileLocation))
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
    /// Initialize SecureStorage to store data in shared UserDefaults.
    ///
    /// - Parameters:
    ///   - sharedDefaultsId: Shared default's suite name from Application group capability.
    ///   - keychainAccessGroup: If provided, keys will be stored in keychain access group. Requires Keychain Sharing capability
    ///   - keychainAccessControl: Access control for the keychain item. Default value is strictest policy kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
    /// - Throws: Throws initialization failes error if shared defaults could not be initialized.
    public init(sharedDefaultsId: String, keychainAccessGroup: String?, keychainAccessControl: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) throws {
        guard let sharedDefaults = UserDefaults.init(suiteName: sharedDefaultsId) else {
            throw SecureStorageError.initializationFailed
        }
        self.storageType = .sharedDefaults(sharedDefaults)
        self.keychainHandler = KeychainHandler(accessGroup: keychainAccessGroup, accessControlType: keychainAccessControl)
    }
    
    
    //MARK:- Public methods -
    
    
    /// Store objects with AES256 encryption at specified location/defaults.
    ///
    /// - Parameters:
    ///   - object: Object that will be archived, encrypted and stored
    ///   - key: Key to which is mapped to the object to be stored
    /// - Throws: Throws specific error based on which task has failed ex. Keychain access has failed, encryption has failed etc.
    public func store(_ object: Any, for key: String) throws {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: object)
        let secureAccessKey = try fetchSecureAccessKey()
        let encryptedData = try archivedData.encrypt(using: secureAccessKey, iv: SecureKeyGenerator.initializationVector(from: secureAccessKey))
        try store(data: encryptedData, for: key)
    }
    
    
    /// Retrieve object for specified key, decrypt and unarchive it before returning
    ///
    /// - Parameter key: Key for which object is to be retrieved
    /// - Returns: Object that is to be retrieved for the key.
    /// - Throws: Throws specific error based on which task has failed ex. Keychain access has failed, decryption has failed etc.
    public func fetchObject(for key: String) throws -> Any {
        let encryptedData = try fetch(for: key)
        let secureAccessKey = try fetchSecureAccessKey()
        let decryptedData = try encryptedData.decrypt(using: secureAccessKey)
        let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: decryptedData)
        if let unarchivedData = unarchivedData {
            return unarchivedData
        }
        throw SecureStorageError.unarchivingFailed
    }
    
    
    /// Removes the object for the specified key. Fails silently if object could not be found for specified key and/or location.
    ///
    /// - Parameter key: Key for which object is to be deleted.
    public func removeObject(for key: String) {
        switch storageType {
        case .defaults(let defaults), .sharedDefaults(let defaults):
            defaults.removeObject(forKey: key)
        case .file(let storageLocation):
            try? FileManager.default.removeItem(at: storageLocation)
        }
    }
    
    
    //MARK:- Private methods -
    func fetchSecureAccessKey() throws -> Data {
        var secureAccessKey: Data! = nil;
        do {
            secureAccessKey = try self.keychainHandler.fetchObject(for: Constants.Keychain.secureKeyIdentifier)
        } catch let error as SecureStorageError where error == .keychainItemNotFound || error == .keychainReadFailed {
            try? self.keychainHandler.removeObject(for: Constants.Keychain.secureKeyIdentifier)
            secureAccessKey = try SecureKeyGenerator.secureAccessKey()
            try self.keychainHandler.store(object: secureAccessKey, for: Constants.Keychain.secureKeyIdentifier)
        }
        return secureAccessKey
    }
    
    
    func store(data: Data, for key: String) throws {
        switch storageType {
        case .defaults(let defaults), .sharedDefaults(let defaults):
            defaults.set(data, forKey: key)
        case .file (let storageLocation):
            let fileLocation = storageLocation.appendingPathComponent(key)
            do {
                try data.write(to: fileLocation, options: .completeFileProtection)
            } catch {
                throw SecureStorageError.fileWritingFailed
            }
        }
    }
    
    
    func fetch(for key: String) throws -> Data {
        switch storageType {
        case .defaults(let defaults), .sharedDefaults(let defaults):
            if let data = defaults.value(forKey: key) as? Data {
                return data
            }
            throw SecureStorageError.objectNotFound
        case .file(let storageLocation):
            let fileLocation = storageLocation.appendingPathComponent(key)
            do {
                let data = try Data.init(contentsOf: fileLocation)
                return data
            } catch {
                throw SecureStorageError.fileReadingFailed
            }
        }
    }
}
