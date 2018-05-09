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


class SecureKeyGenerator {
    
    class func initializationVector(from key: Data, length: Int = kCCBlockSizeAES128) -> Data {
        let allowedCharacters = "abcdefghZijklYmXnWoVpUqTrSsRtQuPvOwNxMyLzK0J1I2H3G4F5E6D7C8B9A"
        var randomString = ""
        
        for _ in 0 ..< length {
            let randomIndex = arc4random_uniform(UInt32(allowedCharacters.count))
            randomString.append(allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: randomIndex)])
        }
        let randomData = Data(randomString.utf8)
        var hash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key.pointer(), key.count, randomData.pointer(), randomData.count, hash.mutablePointer())
        return hash.subdata(in: kCCBlockSizeAES128/2 ..< (kCCBlockSizeAES128 + kCCBlockSizeAES128/2))
    }
    
    
    class func secureAccessKey() throws -> Data {
        var randomData = Data(count: kCCKeySizeAES128+kCCKeySizeAES256+kCCKeySizeAES192)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomData.count, randomData.mutablePointer())
        if result != errSecSuccess {
            throw SecureStorageError.keyGenerationFailed
        }
        randomData = randomData.subdata(in: kCCKeySizeAES192 ..< (kCCKeySizeAES192 + kCCKeySizeAES256))
        let hashSalt = SecureKeyGenerator.pbkdfSalt
        var rounds = CCCalibratePBKDF(CCPBKDFAlgorithm(kCCPBKDF2), randomData.count, hashSalt.count,
                                      CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), kCCKeySizeAES256, 100)
        if rounds < 1000 {
            rounds = 1000
        }
        var accessKey = Data(count: size_t(kCCKeySizeAES256))
        let status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), randomData.pointer(), randomData.count, hashSalt.pointer(), hashSalt.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), rounds, accessKey.mutablePointer(), accessKey.count)
        if status != errSecSuccess {
            throw SecureStorageError.keyGenerationFailed
        }
        return accessKey
    }
    
    
    static var pbkdfSalt: Data {
        var saltBytes: [UInt32] = []
        for _ in 0 ..< kCCKeySizeAES256 {
            saltBytes.append(arc4random())
        }
        return Data(buffer: UnsafeBufferPointer(start: &saltBytes, count: saltBytes.count))
    }
}



extension Data {
    
    mutating func mutablePointer<T>() -> UnsafeMutablePointer<T> {
        return self.withUnsafeMutableBytes { return $0 }
    }
    
    
    func pointer<T>() -> UnsafePointer<T> {
        return self.withUnsafeBytes {return $0 }
    }
}
