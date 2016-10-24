import UIKit
import XCTest
import Blackhole

class ReceivingTestCase: BlackholeTestCase {
    // MARK: - Basic Tests
    func testSimpleSendingReceiveSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        let receiveExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(result: TestSession.EmitResult(success: true))
        
        let messegeListener = MessageListener { message -> BlackholeMessage? in
            guard let value = message["someKey"], value is String, value as! String == "stringValue" else {
                XCTAssert(false)
                return nil
            }
            
            receiveExpectation.fulfill()
            return nil
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.sendMessage(message, withIdentifier: identifier, success: {
                sendExpectation.fulfill()
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
    
    func testTripleSendingReceivedSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        let receiveExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(result: TestSession.EmitResult(success: true))
        self.session.emit(result: TestSession.EmitResult(success: true))
        self.session.emit(result: TestSession.EmitResult(success: true))
        
        var counter = 3
        
        let messegeListener = MessageListener { message -> BlackholeMessage? in
            guard let value = message["someKey"], value is String, value as! String == "stringValue" else {
                XCTAssert(false)
                return nil
            }
            
            counter -= 1
            if counter == 0 {
                receiveExpectation.fulfill()
            }
            
            return nil
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.sendMessage(message, withIdentifier: identifier)
            try emitter.sendMessage(message, withIdentifier: identifier)
            try emitter.sendMessage(message, withIdentifier: identifier, success: {
                sendExpectation.fulfill()
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
    
}
