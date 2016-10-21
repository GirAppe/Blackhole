import UIKit
import XCTest
import Blackhole

class Tests: XCTestCase {
    
    var emitter: Blackhole!
//    var receiver: Blackhole!
    
    override func setUp() {
        super.setUp()
        
//        // Setup black holes
//        emitter = Blackhole(type: TestSession.self)
//        receiver = Blackhole(type: TestSession.self)
//        // Setup emitters and receivers
//        TestSession.defaultSession.emitter = emitter
//        TestSession.defaultSession.receiver = receiver
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
//        TestSession.defaultSession.invalidate()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
//    func testSimpleSending() {
//        let identifier = "someIdentifier"
//        let message: BlackholeMessage = ["someKey":"stringValue"]
//        
//        do {
//            try emitter.sendMessage(message, withIdentifier: identifier, success: {
////                XCTAssert(true, "Message sent!")
//            }, failure: { error in
////                XCTAssert(false, "Error sending: \(error)")
//            })
//        }
//        catch {
//            XCTAssert(false, "Error sending: \(error)")
//        }
//    }
//    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
