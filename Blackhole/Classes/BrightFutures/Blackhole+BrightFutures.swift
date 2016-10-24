//
//  Blackhole+BrightFutures.swift
//  Pods
//
//  Created by Andrzej Michnia on 24.10.2016.
//
//

import Foundation
import BrightFutures

func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}
func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}


fileprivate class BlackholeContainer {
    var promisedSession = Promise<BlackholeSession,BlackholeError>()
    var futureSession: Future<BlackholeSession,BlackholeError> {
        return promisedSession.future
    }
}
fileprivate var entityKey: UInt8 = 0 // We still need this boilerplate
fileprivate extension Blackhole {
    fileprivate var blackholeContainer: BlackholeContainer { // cat is *effectively* a stored property
        get {
            return associatedObject(base: self, key: &entityKey)
            { return BlackholeContainer() } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &entityKey, value: newValue) }
    }
}

extension Blackhole {
    
    func didStartedSession() {
        guard let session = self.session else {
            NotificationCenter.default.addObserver(self, selector: #selector(didStartedSession), name: NSNotification.Name(rawValue: BlackholeStartedSessionNotification), object: self)
            return
        }
        
        self.blackholeContainer.promisedSession.success(session)
        NotificationCenter.default.removeObserver(self)
    }
    
    public func promiseSession() -> Future<BlackholeSession,BlackholeError> {
        self.didStartedSession()
        
        return self.blackholeContainer.futureSession
    }
    
    // MARK: - Message Promises
    public func promiseSendMessage(_ message: BlackholeMessageConvertible, withIdentifier identifier: String) -> Future<Void,BlackholeError> {
        return self.promiseSession()
        .flatMap { _ -> Future<Void, BlackholeError> in
            let promise = Promise<Void,BlackholeError>()
            
            do {
                try self.sendMessage(message, withIdentifier: identifier, success: {
                    promise.success()
                }, failure: { error in
                    promise.failure(error ?? BlackholeError.unknown)
                })
            }
            catch {
                promise.failure((error as? BlackholeError) ?? BlackholeError.unknown)
            }
            
            return promise.future
        }
    }
    
//    func promiseResponseForMessage<T:WormholeMessageMappable>(_ message: [String:AnyObject], withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
//        return self.promiseSession()
//            .flatMap { session -> Future<T, BlackholeError> in
//                let promise = Promise<T,BlackholeError>()
//                
//                DispatchQueue.global(qos: .background).async {
//                    let wormholeMessage: [String:AnyObject] = [
//                        Key.Identifier: identifier as AnyObject,
//                        Key.Body: message as AnyObject
//                    ]
//                    
//                    DDLogCommunication("Sending message;\(identifier)")
//                    session.sendMessage(wormholeMessage, replyHandler: { reply in
//                        DDLogCommunication("Sending SUCCESS;\(identifier)")
//                        if let response = T(message: reply as [String : AnyObject]) {
//                            DDLogCommunication("Response Serialization SUCCESS;\(identifier)")
//                            promise.success(response)
//                        }
//                        else {
//                            DDLogCommunication("Response Serialization FAILURE;\(identifier)")
//                            promise.failure(BlackholeError.unknownResponse(reply as [String : AnyObject]))
//                        }
//                        }, errorHandler: { error in
//                            DDLogCommunication("Sending FAILURE;\(identifier);\(error)")
//                            promise.failure(BlackholeError.sendingError(error))
//                    })
//                }
//                
//                return promise.future
//        }
//    }
//    
//    // MARK: - Promise Send Data
//    func promiseSendObject(_ object: WormholeDataConvertible, withIdentifier identifier: String) -> Future<Void,BlackholeError> {
//        let data = object.dataRepresentation()
//        
//        if data.count < DataSize.MessageSize {
//            return self.promiseSendObjectAsMessage(data, withIdentifier: identifier)
//        }
//        else {
//            return self.promiseSendObjectAsFile(data, withIdentifier: identifier)
//        }
//    }
//    
//    func promiseResponseForObject<T:WormholeDataMappable>(_ object: WormholeDataConvertible, withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
//        let data = object.dataRepresentation()
//        
//        if data.count < DataSize.MessageSize {
//            return self.promiseResponseForObjectAsMessage(data, withType: type, andIdentifier: identifier)
//        }
//        else {
//            return self.promiseResponseForObjectAsFile(data, withType: type, withIdentifier: identifier)
//        }
//        
//    }
//    
//    // MARK: - Send data as message
//    func promiseSendObjectAsMessage(_ object: WormholeDataConvertible, withIdentifier identifier: String) -> Future<Void,BlackholeError> {
//        return self.promiseSession()
//            .flatMap { session -> Future<Void, BlackholeError> in
//                let promise = Promise<Void,BlackholeError>()
//                
//                DispatchQueue.global(qos: .background).async {
//                    let wormholeMessage: [String:AnyObject] = [
//                        Key.Identifier: identifier as AnyObject,
//                        Key.Body: object.dataRepresentation() as AnyObject
//                    ]
//                    
//                    let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
//                    
//                    DDLogCommunication("Sending data;\(identifier)")
//                    session.sendMessageData(wormholeData, replyHandler: { _ in
//                        DDLogCommunication("Sending SUCCESS;\(identifier)")
//                        promise.success()
//                        }, errorHandler: { error in
//                            DDLogCommunication("Sending FAILURE;\(identifier);\(error)")
//                            promise.failure(BlackholeError.sendingError(error))
//                    })
//                }
//                
//                return promise.future
//        }
//    }
//    
//    func promiseResponseForObjectAsMessage<T:WormholeDataMappable>(_ object: WormholeDataConvertible, withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
//        return self.promiseSession().flatMap { session -> Future<T, BlackholeError> in
//            let promise = Promise<T,BlackholeError>()
//            
//            DispatchQueue.global(qos: .background).async {
//                let wormholeMessage: [String:AnyObject] = [
//                    Key.Identifier: identifier as AnyObject,
//                    Key.Body: object.dataRepresentation() as AnyObject
//                ]
//                
//                let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
//                
//                DDLogCommunication("Sending data;\(identifier)")
//                session.sendMessageData(wormholeData, replyHandler: { reply in
//                    DDLogCommunication("Sending SUCCESS;\(identifier)")
//                    if let response = T(data: reply) {
//                        DDLogCommunication("Response Serialization SUCCESS;\(identifier)")
//                        promise.success(response)
//                    }
//                    else {
//                        DDLogCommunication("Response Serialization FAILURE;\(identifier)")
//                        promise.failure(BlackholeError.invalidData)
//                    }
//                    }, errorHandler: { error in
//                        DDLogCommunication("Sending FAILURE;\(identifier);\(error)")
//                        promise.failure(BlackholeError.sendingError(error))
//                })
//            }
//            
//            return promise.future
//        }
//    }
//    
//    // MARK: - Send Data as File
//    func promiseSendObjectAsFile(_ object: WormholeDataConvertible, withIdentifier identifier: String) -> Future<Void,BlackholeError> {
//        return self.promiseSession()
//            .flatMap { session -> Future<Void, BlackholeError> in
//                let promise = Promise<Void,BlackholeError>()
//                
//                DispatchQueue.global(qos: .background).async {
//                    guard let tempUrl = FileManager.cacheTemporaryFileUrl() else {
//                        promise.failure(BlackholeError.invalidData)
//                        return
//                    }
//                    
//                    let wormholeMessage: [String:AnyObject] = [
//                        Key.Identifier: identifier as AnyObject,
//                        Key.Body: object.dataRepresentation() as AnyObject
//                    ]
//                    
//                    let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
//                    
//                    do {
//                        try wormholeData.write(to: tempUrl)
//                    }
//                    catch {
//                        promise.failure(BlackholeError.unknown)
//                        return
//                    }
//                    
//                    DDLogCommunication("Sending file;\(tempUrl)")
//                    
//                    // Add file transfer completion block
//                    self.fileTransfers[tempUrl.absoluteString] = { error in
//                        self.fileTransfers.removeValue(forKey: tempUrl.absoluteString)
//                        
//                        if error == nil {
//                            DDLogCommunication("Sending file success;\(tempUrl)")
//                            promise.success()
//                        }
//                        else {
//                            DDLogCommunication("Sending failure;\(tempUrl)")
//                            promise.failure(BlackholeError.sendingError(error!))
//                        }
//                    }
//                    
//                    session.transferFile(tempUrl, metadata: nil)
//                }
//                
//                return promise.future
//        }
//    }
//    
//    func promiseResponseForObjectAsFile<T:WormholeDataMappable>(_ object: WormholeDataConvertible, withType type: T.Type, withIdentifier identifier: String) -> Future<T,BlackholeError> {
//        return self.promiseSession()
//            .flatMap { session -> Future<T, BlackholeError> in
//                let promise = Promise<T,BlackholeError>()
//                
//                DispatchQueue.global(qos: .background).async {
//                    guard let tempUrl = FileManager.cacheTemporaryFileUrl() else {
//                        promise.failure(BlackholeError.invalidData)
//                        return
//                    }
//                    
//                    let wormholeMessage: [String:AnyObject] = [
//                        Key.Identifier: identifier as AnyObject,
//                        Key.Body: object.dataRepresentation() as AnyObject,
//                        Key.FileTransferName: tempUrl.absoluteString as AnyObject
//                    ]
//                    
//                    let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
//                    
//                    do {
//                        try wormholeData.write(to: tempUrl)
//                    }
//                    catch {
//                        promise.failure(BlackholeError.unknown)
//                        return
//                    }
//                    
//                    DDLogCommunication("Sending file;\(tempUrl)")
//                    
//                    // Add file transfer completion block
//                    self.fileTransfers[tempUrl.absoluteString] = { error in
//                        self.fileTransfers.removeValue(forKey: tempUrl.absoluteString)
//                        
//                        if error == nil {
//                            DDLogCommunication("Sending file success;\(tempUrl)")
//                        }
//                        else {
//                            DDLogCommunication("Sending failure;\(tempUrl)")
//                            promise.tryFailure(BlackholeError.sendingError(error!))
//                        }
//                    }
//                    
//                    // Prepare response listener
//                    let responseListener = DataListener { reply in
//                        DDLogCommunication("RESPONSE SUCCESS;\(identifier)")
//                        if let response = T(data: reply) {
//                            DDLogCommunication("Response Serialization SUCCESS;\(identifier)")
//                            promise.success(response)
//                        }
//                        else {
//                            DDLogCommunication("Response Serialization FAILURE;\(identifier)")
//                            promise.failure(BlackholeError.invalidData)
//                        }
//                        
//                        return nil
//                    }
//                    responseListener.autoremoved = true
//                    self.addListener(responseListener, forIdentifier: tempUrl.absoluteString)
//                    
//                    // Send file
//                    session.transferFile(tempUrl, metadata: nil)
//                }
//                
//                return promise.future
//        }
//    }
    
}
