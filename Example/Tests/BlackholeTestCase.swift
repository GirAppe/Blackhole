import UIKit
import XCTest
import Blackhole

class BlackholeTestCase: XCTestCase {
    
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
    
}
