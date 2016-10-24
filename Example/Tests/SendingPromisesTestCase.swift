import UIKit
import XCTest
import Blackhole

class SendingPromisesTestCase: BlackholeTestCase {

    // MARK: - Basic Tests
    func testSimpleSendingSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let expectation: XCTestExpectation = self.expectation(description: "Expect message to be sent")
        
        self.session.emit(result: TestSession.EmitResult(success: true))
        
        emitter.promiseSendMessage(message, withIdentifier: identifier)
        .onSuccess {
            expectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false)
        }
        
        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
        }
    }
    
}
