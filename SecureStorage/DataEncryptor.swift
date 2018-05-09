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
