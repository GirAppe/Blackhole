import UIKit
import XCTest
import Blackhole
import BrightFutures

class ReceivingPromisesTestCase: BlackholeTestCase {
    // MARK: - Basic Tests
    func testSimpleSendingReceiveSuccess() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        let receiveExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(TestSession.EmitResult(success: true))
        
        let messegeListener = MessageListener { message -> BlackholeMessage? in
            guard let value = message["someKey"], value is String, value as! String == "stringValue" else {
                XCTAssert(false)
                return nil
            }
            
            receiveExpectation.fulfill()
            return nil
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        emitter.promiseSendMessage(message, withIdentifier: identifier)
        .onFailure { error in
            XCTAssert(false, "Error sending: \(error)")
        }
        .onSuccess {
            sendExpectation.fulfill()
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
        
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        
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
        
        let _ = emitter.promiseSendMessage(message, withIdentifier: identifier)
        .flatMap { _ -> Future<Void,BlackholeError> in
            return self.emitter.promiseSendMessage(message, withIdentifier: identifier)
        }
        .flatMap { _ -> Future<Void,BlackholeError> in
            return self.emitter.promiseSendMessage(message, withIdentifier: identifier)
        }
        .onSuccess {
            sendExpectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false, "Error sending: \(error)")
        }
        
        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
        }
    }
    
}
