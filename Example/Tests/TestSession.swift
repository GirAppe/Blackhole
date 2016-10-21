////
////  TestSession.swift
////  Blackhole
////
////  Created by Andrzej Michnia on 21.10.2016.
////  Copyright © 2016 CocoaPods. All rights reserved.
////
//
//import Foundation
//import WatchConnectivity
//import Blackhole
//
//class TestSession: BlackholeSession {
//    // MARK: - Typedefs
//    typealias SentMessageTuple = (message: BlackholeMessage, replyHandler: ((BlackholeMessage)->Swift.Void)?, errorHandler: ((Error)->Swift.Void)?)
//    typealias SentDataTuple = (data: Data, replyHandler: ((Data) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?)
//    typealias SentFileTuple = (fileUrl: URL, metadata: BlackholeMessage?)
//    
//    // MARK: - Properties
//    static func isSupported() -> Bool { return true }
//    var isReachable: Bool = true
//    static func `main`() -> BlackholeSession { return TestSession.defaultSession }
//    static var defaultSession = TestSession()
//    weak var delegate: WCSessionDelegate?
//    
//    var emitter: Blackhole!
//    var receiver: Blackhole!
//    
//    var emitQueue = Queue<Any>()
//    
//    let session = WCSession.default()
//    
//    // MARK: - Lifecycle
//    
//    // MARK: - Actions
//    func emit(result: EmitResult) {
//        guard let emitObject = emitQueue.dequeue() else {
//            return
//        }
//        
//        if emitObject is SentMessageTuple {
//            let messageObject = emitObject as! SentMessageTuple
//            
//            if result.success {
//                passMessage(messageObject)
//            }
//            else {
//                failMessage(messageObject, withError: result.error)
//            }
//        }
//        if emitObject is SentDataTuple {
//            let dataObject = emitObject as! SentDataTuple
//            
//            if result.success {
//                passData(dataObject)
//            }
//            else {
//                failData(dataObject, withError: result.error)
//            }
//        }
//    }
//    
//    // MARK: - Private
//    private func passMessage(_ message: SentMessageTuple) {
//        if let _ = message.replyHandler {
//            receiver.session(session, didReceiveMessage: message.message, replyHandler: message.replyHandler!)
//        }
//        else {
//            receiver.session(session, didReceiveMessage: message.message)
//        }
//    }
//    
//    private func failMessage(_ message: SentMessageTuple, withError error: Error!) {
//        message.errorHandler?(error)
//    }
//    
//    private func passData(_ data: SentDataTuple) {
//        if let _ = data.replyHandler {
//            receiver.session(session, didReceiveMessageData: data.data, replyHandler: data.replyHandler!)
//        }
//        else {
//            receiver.session(session, didReceiveMessageData: data.data)
//        }
//    }
//    
//    private func failData(_ data: SentDataTuple, withError error: Error!) {
//        data.errorHandler?(error)
//    }
//    
//    // MARK: - Session Conformance
//    func activate() {
//    }
//    
//    func invalidate() {
//        self.emitQueue = Queue<Any>()
//        emitter = nil
//        receiver = nil
//    }
//    
//    func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?) {
//        emitQueue.append(newElement: (message: message, replyHandler: replyHandler, errorHandler: errorHandler))
//    }
//    
//    func sendMessageData(_ data: Data, replyHandler: ((Data) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?) {
//        emitQueue.append(newElement: (data: data, replyHandler: replyHandler, errorHandler: errorHandler))
//    }
//    
//    func transferFile(_ file: URL, metadata: [String : Any]?) -> WCSessionFileTransfer {
//        emitQueue.append(newElement: (fileUrl: file, metadata: metadata))
//        return WCSessionFileTransfer()
//    }
//    
//    // MARK: - Defines
//    struct EmitResult {
//        let success: Bool
//        let error: Error = NSError()
//    }
//    
//}
