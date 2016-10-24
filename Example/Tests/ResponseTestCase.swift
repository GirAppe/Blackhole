import UIKit
import XCTest
import Blackhole

class ResponseTestCase: BlackholeTestCase {
    // MARK: - Basic Tests
    func testSimpleSendingResponseSuccess() {
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
            return ["anotherKey":12]
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.responseForMessage(message, withType: BlackholeMessage.self, andIdentifier: identifier, success: { message in
                guard let value = message["anotherKey"], value is Int, value as! Int == 12 else {
                    XCTAssert(false)
                    return
                }
                
                sendExpectation.fulfill()
            }, failure: { error in
                XCTAssert(false)
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
    
    func testSimpleSendingResponseFailure() {
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
            try emitter.responseForMessage(message, withType: BlackholeMessage.self, andIdentifier: identifier, success: { message in
                guard let value = message["anotherKey"], value is Int, value as! Int == 12 else {
                    sendExpectation.fulfill()
                    return
                }
                
                XCTAssert(false)
            }, failure: { error in
                XCTAssert(false)
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
    
    // MARK: - Moderate Tests
    struct Cat: BlackholeMessageMappable,BlackholeMessageConvertible {
        let name: String
        let breed: Breed
        enum Breed: String {
            case persian
            case siamese
            case sphynx
            case bengal
        }
        
        init(name: String, breed: Breed) {
            self.name = name
            self.breed = breed
        }
        
        init?(message: BlackholeMessage) {
            guard let name = message["name"] as? String,
                let breedValue = message["breed"] as? String,
                let breed = Breed(rawValue: breedValue)
            else {
                return nil
            }
            
            self.init(name: name, breed: breed)
        }
        
        func messageRepresentation() -> BlackholeMessage {
            return [
                "name":name,
                "breed":breed.rawValue
            ]
        }
    }
    
    func testObjectSendingResponseSuccess() {
        let cat1 = Cat(name: "Pussy", breed: .persian)
        let cat2 = Cat(name: "Dotty", breed: .bengal)
        let cat3 = Cat(name: "Tetty", breed: .siamese)
        let cat4 = Cat(name: "Pratt", breed: .sphynx)
        
        let identifier = "CatRequest"
        
        let persianExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        let bengalExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        let siameseExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        
        
        self.session.emit(result: TestSession.EmitResult(success: true))
        self.session.emit(result: TestSession.EmitResult(success: true))
        self.session.emit(result: TestSession.EmitResult(success: true))
        
        let catListener = MessageListener { message -> BlackholeMessage? in
            guard let breed = message["breed"] as? String else {
                return nil
            }
            
            switch breed {
            case "persian":
                return cat1.messageRepresentation()
            case "bengal":
                return cat2.messageRepresentation()
            case "siamese":
                return cat3.messageRepresentation()
            case "sphynx":
                return cat4.messageRepresentation()
            default:
                return nil
            }
        }
        receiver.addListener(catListener, forIdentifier: identifier)
        
        do {
            XCTAssert(self.session === emitter.session)
            
            let persianRequestMessage: BlackholeMessage = ["breed":"persian"]
            try emitter.responseForMessage(persianRequestMessage, withType: Cat.self, andIdentifier: identifier, success: { cat in
                XCTAssertEqual(cat.name, "Pussy")
                XCTAssertEqual(cat.breed, Cat.Breed.persian)
                persianExpectation.fulfill()
            }, failure: { error in
                XCTAssert(false)
            })
            
            let bengalRequestMessage: BlackholeMessage = ["breed":"bengal"]
            try emitter.responseForMessage(bengalRequestMessage, withType: Cat.self, andIdentifier: identifier, success: { cat in
                XCTAssertEqual(cat.name, "Dotty")
                XCTAssertEqual(cat.breed, Cat.Breed.bengal)
                bengalExpectation.fulfill()
            }, failure: { error in
                XCTAssert(false)
            })
            
            let siameseRequestMessage: BlackholeMessage = ["breed":"siamese"]
            try emitter.responseForMessage(siameseRequestMessage, withType: Cat.self, andIdentifier: identifier, success: { cat in
                XCTAssertEqual(cat.name, "Tetty")
                XCTAssertEqual(cat.breed, Cat.Breed.siamese)
                siameseExpectation.fulfill()
            }, failure: { error in
                XCTAssert(false)
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
    
    // MARK: - File sending tests
    func testImageSendingResponseSuccess() {
        let identifier = "someIdentifier"
        
        let bundle = Bundle(for: ResponseTestCase.self)
        
        guard let imagePath = bundle.path(forResource: "blackhole-image", ofType: "jpg") else {
            XCTAssert(false,"Cannot load image path")
            return
        }
        
        guard let imageSent = UIImage(contentsOfFile: imagePath) else {
            XCTAssert(false,"Cannot load image")
            return
        }
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be sent")
        let receiveExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(result: TestSession.EmitResult(success: true))

        let imageListener = ObjectListener(type: UIImage.self) { image in
            let data = image.dataRepresentation()
            
            XCTAssertEqual(data, imageSent.dataRepresentation())
            
            receiveExpectation.fulfill()
        }
        receiver.addListener(imageListener, forIdentifier: identifier)
        
        do {
            XCTAssert(self.session === emitter.session)
            try emitter.sendObject(imageSent, withIdentifier: identifier, success: { 
                sendExpectation.fulfill()
            }, failure: { error in
                XCTAssert(false, "Failure sending: \(error)")
            })
        }
        catch {
            XCTAssert(false, "Error sending: \(error)")
        }
        
        self.waitForExpectations(timeout: 60) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
            
            for tempFile in self.session.temporaryFilesThatShouldBeDeleted {
                XCTAssertFalse(FileManager.default.fileExists(atPath: tempFile.absoluteString), "Temp file not deleted!")
            }
        }
    }
    
}
