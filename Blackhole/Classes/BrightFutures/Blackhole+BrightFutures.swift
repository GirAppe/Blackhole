//
//  Blackhole+BrightFutures.swift
//  Pods
//
//  Created by Andrzej Michnia on 24.10.2016.
//
//

import Foundation
import BrightFutures

fileprivate func associatedObject<ValueType: AnyObject>(
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
fileprivate func associateObject<ValueType: AnyObject>(
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
fileprivate var veryCustomKey: UInt8 = 0 // We still need this boilerplate
fileprivate extension Blackhole {
    fileprivate var blackholeContainer: BlackholeContainer { // cat is *effectively* a stored property
        get {
            return associatedObject(base: self, key: &veryCustomKey)
            { return BlackholeContainer() } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &veryCustomKey, value: newValue) }
    }
}

extension Blackhole {
    
    func didStartedSession() {
        guard let session = self.session else {
            NotificationCenter.default.addObserver(self, selector: #selector(didStartedSession), name: NSNotification.Name(rawValue: BlackholeStartedSessionNotification), object: self)
            return
        }
        
        self.blackholeContainer.promisedSession.trySuccess(session)
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
    
    public func promiseResponseForMessage<T:BlackholeMessageMappable>(_ message: BlackholeMessageConvertible, withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
        return self.promiseSession()
        .flatMap { _ -> Future<T, BlackholeError> in
            let promise = Promise<T,BlackholeError>()
            
            do {
                try self.responseForMessage(message, withType: T.self, andIdentifier: identifier, success: { object in
                    promise.success(object)
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
   
    
    public func promiseObjectForMessage<T:BlackholeDataMappable>(_ message: BlackholeMessageConvertible, withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
        
        let messageObject: NSDictionary = message.messageRepresentation() as NSDictionary
        
        return self.promiseSession()
        .flatMap { _ -> Future<T, BlackholeError> in
            let promise = Promise<T,BlackholeError>()
            
            do {
                try self.responseForObject(messageObject, withType: T.self, andIdentifier: identifier, success: { object in
                    promise.success(object)
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
    
    // MARK: - Promise Send Data
    public func promiseSendObject(_ object: BlackholeDataConvertible, withIdentifier identifier: String) -> Future<Void,BlackholeError> {
        return self.promiseSession()
        .flatMap { _ -> Future<Void, BlackholeError> in
            let promise = Promise<Void,BlackholeError>()
            
            do {
                try self.sendObject(object, withIdentifier: identifier, success: {
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
    
    public func promiseResponseForObject<T:BlackholeDataMappable>(_ object: BlackholeDataConvertible, withType type: T.Type, andIdentifier identifier: String) -> Future<T,BlackholeError> {
        return self.promiseSession()
        .flatMap { _ -> Future<T, BlackholeError> in
            let promise = Promise<T,BlackholeError>()
            
            do {
                try self.responseForObject(object, withType: T.self, andIdentifier: identifier, success: { object in
                    promise.success(object)
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
    
}
