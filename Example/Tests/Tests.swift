import UIKit
import XCTest
import Blackhole

class Tests: XCTestCase {
    
    var session: TestSession!
    var emitter: Blackhole = Blackhole(type: TestSession.self)
    var receiver: Blackhole = Blackhole(type: TestSession.self)
    
    override func setUp() {
        super.setUp()

        self.session = TestSession(emitter: &emitter, receiver: &receiver)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.session.invalidate()
    }
    
    // MARK: - Basic Tests
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testSetup() {
        guard self.session === self.emitter.session else {
            XCTAssert(false)
            return
        }
        
        guard self.session === self.receiver.session else {
            XCTAssert(false)
            return
        }
    }
    
    func testSimpleSendingSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let expectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(result: TestSession.EmitResult(success: true))
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.sendMessage(message, withIdentifier: identifier, success: {
                expectation.fulfill()
            }, failure: { error in
                XCTAssert(false, "Error sending: \(error)")
            })
        }
        catch {
            XCTAssert(false, "Error sending: \(error)")
        }
        
        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
        }
    }
    
    func testSimpleSendingFailure() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let expectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(result: TestSession.EmitResult(success: false))
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.sendMessage(message, withIdentifier: identifier, success: {
                XCTAssert(false, "Should not be there")
            }, failure: { error in
                expectation.fulfill()
            })
        }
        catch {
            XCTAssert(false, "Error sending: \(error)")
        }
        
        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
        }
    }
    
    // MARK: - Measurments
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
