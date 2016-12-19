import UIKit
import XCTest
import Blackhole

class SendingTestCase: BlackholeTestCase {
    // MARK: - Basic Tests
    func testSimpleSendingSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let expectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(TestSession.EmitResult(success: true))
        
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
        
        self.session.emit(TestSession.EmitResult(success: false))
        
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
    
}
