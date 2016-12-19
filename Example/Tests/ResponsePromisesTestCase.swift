import UIKit
import XCTest
import Blackhole

class ResponsePromisesTestCase: BlackholeTestCase {
    // MARK: - Basic Tests
    func testSimpleSendingResponseSuccess() {
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
            return ["anotherKey":12]
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        let _ = emitter.promiseResponseForMessage(message, withType: [String:Int].self, andIdentifier: identifier)
        .onSuccess { responseDict in
            if let value = responseDict["anotherKey"], value == 12 {
                sendExpectation.fulfill()
            }
            else {
                XCTAssert(false)
            }
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
    
    func testSimpleSendingResponseFailure() {
        let identifier = "someIdentifier"
        let message: BlackholeMessage = ["someKey":"stringValue"]
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(TestSession.EmitResult(success: false))
        
        let messegeListener = MessageListener { message -> BlackholeMessage? in
            XCTAssert(false)
            return nil
        }
        receiver.addListener(messegeListener, forIdentifier: identifier)
        
        let _ = emitter.promiseResponseForMessage(message, withType: [String:Int].self, andIdentifier: identifier)
        .onSuccess { responseDict in
            XCTAssert(false)
        }
        .onFailure { error in
            sendExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTAssert(false, "Error sending: \(error)")
            }
        }
    }
    
    // MARK: - Moderate Tests
    struct ACat: BlackholeMessageMappable,BlackholeMessageConvertible {
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
        let cat1 = ACat(name: "Pussy", breed: .persian)
        let cat2 = ACat(name: "Dotty", breed: .bengal)
        let cat3 = ACat(name: "Tetty", breed: .siamese)
        let cat4 = ACat(name: "Pratt", breed: .sphynx)
        
        let identifier = "CatRequest"
        
        // Expect cats
        let persianExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        let bengalExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        let siameseExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        
        // Prepare pattern
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        
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
        
        // Send cats
        let persianRequestMessage: BlackholeMessage = ["breed":"persian"]
        let _ = emitter.promiseResponseForMessage(persianRequestMessage, withType: ACat.self, andIdentifier: identifier)
        .onSuccess { cat in
            XCTAssertEqual(cat.name, "Pussy")
            XCTAssertEqual(cat.breed, ACat.Breed.persian)
            persianExpectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false)
        }
        
        let bengalRequestMessage: BlackholeMessage = ["breed":"bengal"]
        let _ = emitter.promiseResponseForMessage(bengalRequestMessage, withType: ACat.self, andIdentifier: identifier)
        .onSuccess { cat in
            XCTAssertEqual(cat.name, "Dotty")
            XCTAssertEqual(cat.breed, ACat.Breed.bengal)
            bengalExpectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false)
        }
        
        let siameseRequestMessage: BlackholeMessage = ["breed":"siamese"]
        let _ = emitter.promiseResponseForMessage(siameseRequestMessage, withType: ACat.self, andIdentifier: identifier)
        .onSuccess { cat in
            XCTAssertEqual(cat.name, "Tetty")
            XCTAssertEqual(cat.breed, ACat.Breed.siamese)
            siameseExpectation.fulfill()
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
    
    func testCatsSendingResponseSuccess() {
        guard let image = UIImage(named: "bengal") else {
            XCTAssert(false)
            return
        }
        let cat = Cat(name: "Betty", breed: "bengal", image: image)
        
        let identifier = "CatMessage"
        
        // Expect cats
        let catExpectation: XCTestExpectation = self.expectation(description: "Expect cat to be delivered on time")
        
        // Prepare pattern
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        self.session.emit(TestSession.EmitResult(success: true))
        
        let catListener = ObjectListener(type: Cat.self) { receivedCat  in
            print(receivedCat.name)
            print(receivedCat.breed)
            print(receivedCat.image)
            catExpectation.fulfill()
        }
        receiver.addListener(catListener, forIdentifier: identifier)
        
        // Send cats
        emitter.promiseSendObject(cat, withIdentifier: identifier)
        .onSuccess {
            print("cat sent")
        }
        .onFailure { (error) in
            XCTAssert(false,"Error: \(error)")
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
        
        let bundle = Bundle(for: ResponsePromisesTestCase.self)
        
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
        
        self.session.emit(TestSession.EmitResult(success: true))
        
        let imageListener = ObjectListener(type: UIImage.self) { image in
            let data = image.dataRepresentation()
            
            XCTAssertEqual(data, imageSent.dataRepresentation())
            
            receiveExpectation.fulfill()
        }
        receiver.addListener(imageListener, forIdentifier: identifier)
        
        let _ = emitter.promiseSendObject(imageSent, withIdentifier: identifier)
        .onSuccess {
            sendExpectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false)
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
    
    func testImageObjectResponderSuccess() {
        let identifier = "someIdentifier"
        
        let message = ["image":"blackhole"]
        
        let bundle = Bundle(for: ResponsePromisesTestCase.self)
        
        guard let imagePath = bundle.path(forResource: "blackhole-image", ofType: "jpg") else {
            XCTAssert(false,"Cannot load image path")
            return
        }
        
        guard let imageResponse = UIImage(contentsOfFile: imagePath) else {
            XCTAssert(false,"Cannot load image")
            return
        }
        
        let sendExpectation: XCTestExpectation = self.expectation(description: "Expect message to be sent")
        let receiveExpectation: XCTestExpectation = self.expectation(description: "Expect message to be delivered")
        
        self.session.emit(TestSession.EmitResult(success: true))
        
        let responder = MessageObjectResponder { message -> UIImage? in
            XCTAssertEqual((message["image"] as? String) ?? "", "blackhole")
            
            receiveExpectation.fulfill()
            return imageResponse
        }
        receiver.addListener(responder, forIdentifier: identifier)
        
        let _ = emitter.promiseObjectForMessage(message, withType: UIImage.self, andIdentifier: identifier)
        .onSuccess { image in
            XCTAssertEqual(image.dataRepresentation(), imageResponse.dataRepresentation())
            sendExpectation.fulfill()
        }
        .onFailure { error in
            XCTAssert(false)
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
