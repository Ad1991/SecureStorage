//
//  DataEncryptor.swift
//  StorageProvider
//
//  Created by Adarsh Kumar Rai on 22/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation


extension Data {
    
    func encrypt(using key: Data, iv: Data) throws -> Data {
        
        var encryptedData = Data(count: size_t(kCCBlockSizeAES128 + self.count + kCCBlockSizeAES128))
        var numBytesEncrypted :size_t = 0
        
        let status = CCCrypt(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             key.pointer(),
                             kCCKeySizeAES256,
                             iv.pointer(),
                             self.pointer(),
                             self.count,
                             encryptedData.mutablePointer(),
                             self.count + kCCBlockSizeAES128,
                             &numBytesEncrypted)
        
        if UInt32(status) == UInt32(kCCSuccess) && numBytesEncrypted > 0 {
            var completeEncryptedData = Data()
            completeEncryptedData.append(encryptedData.subdata(in: 0 ..< numBytesEncrypted))
            completeEncryptedData.append(iv)
            return completeEncryptedData
        } else {
            throw SecureStorageError.encryptionFailed
        }
    }
    
    
    func decrypt(using key: Data) throws -> Data {
        
        let iv = self.subdata(in: self.count - kCCBlockSizeAES128 ..< self.count)
        let dataToBeDecrypted = self.subdata(in: 0 ..< self.count - kCCBlockSizeAES128)
        var decryptedData = Data(count: size_t(self.count))
        var numBytesDecrypted: size_t = 0
        let status = CCCrypt(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             key.pointer(),
                             kCCKeySizeAES256,
                             iv.pointer(),
                             dataToBeDecrypted.pointer(),
                             dataToBeDecrypted.count,
                             decryptedData.mutablePointer(),
                             decryptedData.count,
                             &numBytesDecrypted)
        if Int32(status) == Int32(kCCSuccess) && numBytesDecrypted > 0 {
            return decryptedData.subdata(in: 0 ..< numBytesDecrypted)
        } else {
            throw SecureStorageError.decryptionFailed
        }
    }
    
}
