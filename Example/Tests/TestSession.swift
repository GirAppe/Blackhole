//
//  TestSession.swift
//  Blackhole
//
//  Created by Andrzej Michnia on 21.10.2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import WatchConnectivity
import Blackhole

class TestSession: BlackholeSession {
    // MARK: - Typedefs
    typealias SentMessageTuple = (message: BlackholeMessage, replyHandler: ((BlackholeMessage)->())?, errorHandler: ((Error)->())?)
    typealias SentDataTuple = (data: Data, replyHandler: ((Data) -> ())?, errorHandler: ((Error) -> ())?)
    typealias SentFileTuple = (fileUrl: URL, metadata: BlackholeMessage?)
    
    // MARK: - Properties
    static func isSupported() -> Bool { return true }
    var isReachable: Bool = true
    static func `main`() -> BlackholeSession { return TestSession.defaultSession }
    static var defaultSession = TestSession()
    weak var delegate: WCSessionDelegate?
    
    var emitter: Blackhole!
    var receiver: Blackhole!
    
    var emitResults: [EmitResult] = []
    
    let session = WCSession.default()
    
    var temporaryFilesThatShouldBeDeleted: [URL] = []   // Check later, if files removed
    
    // MARK: - Lifecycle
    init() {
        
    }
    
    init(emitter: inout Blackhole, receiver: inout Blackhole) {
        emitter = Blackhole(session: self)
        receiver = Blackhole(session: self)
        self.emitter = emitter
        self.receiver = receiver
    }
    
    // MARK: - Actions
    func emit(_ messageObject: SentMessageTuple) {
        guard let result = emitResults.first else {
            return
        }
        
        emitResults.remove(at: 0)
        
        if result.success {
            passMessage(messageObject)
        }
        else {
            failMessage(messageObject, withError: result.error)
        }
    }
    
    func emit(_ dataObject: SentDataTuple) {
        guard let result = emitResults.first else {
            return
        }
        
        emitResults.remove(at: 0)
        
        if result.success {
            passData(dataObject)
        }
        else {
            failData(dataObject, withError: result.error)
        }
    }
    
    func emit(_ file: URL) {
        guard let result = emitResults.first else {
            return
        }
        
        emitResults.remove(at: 0)
        
        if result.success {
            passFile(file)
        }
        else {
            failFile(file, withError: result.error)
        }
    }
    
    func emit(_ result: EmitResult) {
        emitResults.append(result)
    }
    
    // MARK: - Private
    fileprivate func passMessage(_ message: SentMessageTuple) {
        if let handler = message.replyHandler {
            receiver.session(session, didReceiveMessage: message.message, replyHandler: handler)
        }
        else {
            receiver.session(session, didReceiveMessage: message.message)
        }
    }
    
    fileprivate func failMessage(_ message: SentMessageTuple, withError error: Error!) {
        message.errorHandler?(error)
    }
    
    fileprivate func passData(_ data: SentDataTuple) {
        if let _ = data.replyHandler {
            receiver.session(session, didReceiveMessageData: data.data, replyHandler: data.replyHandler!)
        }
        else {
            receiver.session(session, didReceiveMessageData: data.data)
        }
    }
    
    fileprivate func failData(_ data: SentDataTuple, withError error: Error!) {
        data.errorHandler?(error)
    }
    
    fileprivate func prepareNewFile(_ file: URL) -> URL {
        let url = FileManager.cacheTemporaryFileUrl()!
        do {
            let data = try Data(contentsOf: file)
            try data.write(to: url)
        }
        catch {
            assertionFailure()
        }
        return url
    }
    
    fileprivate func passFile(_ file: URL) {
        let newFile = prepareNewFile(file) // assure copy of file created
        temporaryFilesThatShouldBeDeleted.append(newFile)
        let ecnFile = TestFile(newFile)
        let ecoFileTransfer = TestFileTransfer(file)
        
        // Notify send success
        emitter.session(session, didFinish: ecoFileTransfer, error: nil)
        // Notify receive success
        receiver.session(session, didReceive: ecnFile)
        
    }
    
    fileprivate func failFile(_ file: URL, withError error: Error!) {
        // TODO: Implement
        let ecoFileTransfer = TestFileTransfer(file)
        
        // Notify send success
        emitter.session(session, didFinish: ecoFileTransfer, error: NSError())
    }
    
    // MARK: - Session Conformance
    func activate() {
    }
    
    func invalidate() {
//        self.emitResults = []
//        emitter = nil
//        receiver = nil
    }
    
    func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?) {
        let element: SentMessageTuple = (message: message, replyHandler: replyHandler ?? { _ in }, errorHandler: errorHandler ?? { _ in })
        emit(element)
    }
    
    func sendMessageData(_ data: Data, replyHandler: ((Data) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?) {
        let element: SentDataTuple = (data: data, replyHandler: replyHandler, errorHandler: errorHandler)
        emit(element)
    }
    
    func transferFile(_ file: URL, metadata: [String : Any]?) -> WCSessionFileTransfer {
        emit(file)
        
        temporaryFilesThatShouldBeDeleted.append(file)
        
        return WCSessionFileTransfer()
    }
    
    // MARK: - Defines
    struct EmitResult {
        let success: Bool
        let error: Error = NSError()
    }
    
}

class TestFile: WCSessionFile {
    var testUrl: URL!
    
    override var fileURL: URL {
        return self.testUrl
    }
    
    init(_ url: URL) {
        self.testUrl = url
        super.init()
    }
}

class TestFileTransfer: WCSessionFileTransfer {
    var testFile: TestFile
    
    override var file: WCSessionFile {
        return self.testFile
    }
    
    init(_ url: URL) {
        self.testFile = TestFile(url)
        super.init()
    }
}
