//
//  SecureStorageTests.swift
//  SecureStorageTests
//
//  Created by Adarsh Kumar Rai on 23/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import XCTest
@testable import SecureStorage

class SecureStorageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        let _ = SecureKeyGenerator.pbkdfSalt
//        let data = try? SecureKeyGenerator.secureAccessKey()
//        XCTAssertNotNil(data, "secure access key can not be nil")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            let _ = try? SecureKeyGenerator.secureAccessKey()
        }
    }
    
    func testPerformance() {
        let key = try? SecureKeyGenerator.secureAccessKey()
        self.measure {
            let _ = SecureKeyGenerator.initializationVector(from: key!)
        }
    }
    
}
