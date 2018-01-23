//
//  DataEncryptor.swift
//  StorageProvider
//
//  Created by Adarsh Kumar Rai on 22/01/18.
//  Copyright © 2018 Philips. All rights reserved.
//

import Foundation


extension Data {
    
    func encryptWithAES256(using key: Data, iv: Data) throws -> Data? {
        
        var encryptedData = Data(count: size_t(kCCBlockSizeAES128 + self.count + kCCBlockSizeAES128))
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = encryptedData.withUnsafeMutableBytes { cryptBytes in
            self.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>) in
                    iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>) in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes,
                                kCCKeySizeAES256,
                                ivBytes,
                                dataBytes,
                                self.count,
                                cryptBytes,
                                self.count + kCCBlockSizeAES128,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        if UInt32(cryptStatus) == UInt32(kCCSuccess) && numBytesEncrypted > 0 {
            var completeEncryptedData = Data()
            completeEncryptedData.append(encryptedData)
            completeEncryptedData.append(iv)
            return completeEncryptedData
        } else {
            //Throw Error here
            return nil
        }
    }
    
    
    func decryptWithAES256(using key: Data) throws -> Data {
        let iv = self.subdata(in: self.count - kCCBlockSizeAES128 ..< self.count)
        let dataToBeDecrypted = self.subdata(in: 0 ..< self.count - kCCBlockSizeAES128)
        var decryptedData = Data(count: size_t(self.count - iv.count))
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = decryptedData.withUnsafeMutableBytes { cryptBytes in
            dataToBeDecrypted.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>) in
                    iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>) in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes,
                                kCCKeySizeAES256,
                                ivBytes,
                                dataBytes,
                                self.count,
                                cryptBytes,
                                decryptedData.count,
                                &numBytesDecrypted)
                    }
                }
            }
        }
        
        return decryptedData
    }
    
}
