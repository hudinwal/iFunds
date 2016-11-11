//
//  iFundsTests.swift
//  iFundsTests
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import XCTest
@testable import iFunds


class iFundsTests: XCTestCase {
    
    var coreDataStack: CoreDataStack?
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let exp = expectation(description: "Setup")
        coreDataStack = CoreDataStack(callBack: { 
            print("Stack Init Done")
            exp.fulfill()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSchemeFilling() {
        
        let scheme = Scheme(context: coreDataStack!.mainContext)
        scheme.fill(charSeparatedString: ";;", separatorString: ";")
        XCTAssert(scheme.schemeName == "Birla Sun Life Cash Plus - Daily Dividend", "Test Failed")
    }
}
