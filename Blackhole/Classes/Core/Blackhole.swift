//
//  Blackhole.swift
//  Pods
//
//  Created by Andrzej Michnia on 20.10.2016.
//
//

import Foundation
import WatchConnectivity

// MARK: - Typedefs
typealias BlackholeMessage = [String:Any]
typealias BlackholeSuccessClosure = ()->()
typealias BlackholeFailureClosure = (WormholeError?)->()

// MARK: - Wormhole
class Wormhole: NSObject {
    // MARK: - Private Properties
    internal var session: BlackholeSession?
    internal var listeners: [String:Listener] = [:]             // Listener handlers
    internal var fileTransfers: [String:(BlackholeFailureClosure)] = [:] // File transfer finished handlers - clearup and notify sending success
    
    let sessionType: BlackholeSession.Type
    
    // MARK: - Lifecycle
    init(type: BlackholeSession.Type = WCSession.self){
        self.sessionType = type
        super.init()
        
        activate()
    }
    
    // MARK: - Listeners
    func addListener(_ listener: Listener, forIdentifier identifier: String) {
        self.listeners[identifier] = listener
        listener.wormhole = self
    }
    
    func removeListener(forIdentifier identifier: String) {
        self.listeners.removeValue(forKey: identifier)
    }
    
    func removeListener(_ listener: Listener) {
        let index = self.listeners.index { _,tested -> Bool in
            return tested === listener
        }
        
        if index != nil {
            self.listeners.remove(at: index!)
        }
    }
    
    // MARK: - Messages
    func sendMessage(_ message: WormholeMessageConvertible, withIdentifier identifier: String) throws {
        try self.sendMessage(message, withIdentifier: identifier, success: nil, failure: nil)
    }
    
    func sendMessage(_ message: WormholeMessageConvertible, withIdentifier identifier: String, success:BlackholeSuccessClosure?, failure:BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            let wormholeMessage: BlackholeMessage = [
                Key.Identifier: identifier,
                Key.Body: message.messageRepresentation()
            ]
            
            session.sendMessage(wormholeMessage, replyHandler: { _ in
                DispatchQueue.main.async {
                    success?()
                }
            }, errorHandler: { error in
                DispatchQueue.main.async {
                    failure?(.sendingError(error))
                }
            })
        }
    }
    
    func responseForMessage<T:WormholeMessageMappable>(_ message: WormholeMessageConvertible, withType type: T.Type, andIdentifier identifier: String, success: ((T)->())?, failure: BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            let wormholeMessage: [String:AnyObject] = [
                Key.Identifier: identifier as AnyObject,
                Key.Body: message as AnyObject
            ]
            
            self.session?.sendMessage(wormholeMessage, replyHandler: { reply in
                DispatchQueue.main.async {
                    if let response = T(message: reply as [String : AnyObject]) {
                        success?(response)
                    }
                    else {
                        failure?(WormholeError.unknownResponse(reply))
                    }
                }
            }, errorHandler: { error in
                DispatchQueue.main.async {
                    failure?(WormholeError.sendingError(error))
                }
            })
        }
    }
    
    // MARK: - Data
    func sendObject(_ object: WormholeDataConvertible, withIdentifier identifier: String, success:BlackholeSuccessClosure?, failure:BlackholeFailureClosure?) throws {
        let data = object.dataRepresentation()
        
        if data.count < DataSize.MessageSize {
            try self.sendObject(asMessage: data, withIdentifier: identifier, success: success, failure: failure)
        }
        else {
            try self.sendObject(asFile: data, withIdentifier: identifier, success: success, failure: failure)
        }
    }
    
    func responseForObject<T:WormholeDataMappable>(_ object: WormholeDataConvertible, withType type: T.Type, andIdentifier identifier: String, success: ((T)->())?, failure: BlackholeFailureClosure?) throws {
        let data = object.dataRepresentation()
        
        
        if data.count < DataSize.MessageSize {
            try self.responseForObject(asMessage: data, withType: type, andIdentifier: identifier, success: success, failure: failure)
        }
        else {
            try self.responseForObject(asFile: data, withType: type, andIdentifier: identifier, success: success, failure: failure)
        }
    }
    
    // MARK: - Private data sending methods
    private func sendObject(asMessage object: WormholeDataConvertible, withIdentifier identifier: String, success:BlackholeSuccessClosure?, failure:BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            let wormholeMessage: BlackholeMessage = [
                Key.Identifier: identifier,
                Key.Body: object.dataRepresentation()
            ]
            
            let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
            
            session.sendMessageData(wormholeData, replyHandler: { _ in
                DispatchQueue.main.async {
                    success?()
                }
            }, errorHandler: { error in
                DispatchQueue.main.async {
                    failure?(.sendingError(error))
                }
            })
        }
    }
    
    private func sendObject(asFile object: WormholeDataConvertible, withIdentifier identifier: String, success:BlackholeSuccessClosure?, failure:BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let tempUrl = FileManager.cacheTemporaryFileUrl() else {
                failure?(.invalidData)
                return
            }
            
            let wormholeMessage: BlackholeMessage = [
                Key.Identifier: identifier,
                Key.Body: object.dataRepresentation()
            ]
            
            let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
            
            // Store as file
            do {
                try wormholeData.write(to: tempUrl)
            }
            catch {
                failure?(.fileCachingError)
                return
            }
            
            // Add file transfer completion block
            self.fileTransfers[tempUrl.absoluteString] = { error in
                self.fileTransfers.removeValue(forKey: tempUrl.absoluteString)
                
                DispatchQueue.main.async {
                    if error == nil {
                        success?()
                    }
                    else {
                        failure?(.sendingError(error!))
                    }
                }
            }
            
            session.transferFile(tempUrl, metadata: nil)
        }
    }
    
    private func responseForObject<T:WormholeDataMappable>(asMessage object: WormholeDataConvertible, withType type: T.Type, andIdentifier identifier: String, success: ((T)->())?, failure: BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            let wormholeMessage: BlackholeMessage = [
                Key.Identifier: identifier,
                Key.Body: object.dataRepresentation()
            ]
            
            let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
            
            session.sendMessageData(wormholeData, replyHandler: { reply in
                if let response = T(data: reply) {
                    success?(response)
                }
                else {
                    failure?(.responseSerializationFailure)
                }
            }, errorHandler: { error in
                failure?(.sendingError(error))
            })
        }
    }
    
    private func responseForObject<T:WormholeDataMappable>(asFile object: WormholeDataConvertible, withType type: T.Type, andIdentifier identifier: String, success: ((T)->())?, failure: BlackholeFailureClosure?) throws {
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let tempUrl = FileManager.cacheTemporaryFileUrl() else {
                failure?(WormholeError.invalidData)
                return
            }
            
            let wormholeMessage: BlackholeMessage = [
                Key.Identifier: identifier,
                Key.Body: object.dataRepresentation(),
                Key.FileTransferName: tempUrl.absoluteString
            ]
            
            let wormholeData = NSKeyedArchiver.archivedData(withRootObject: wormholeMessage as NSDictionary)
            
            do {
                try wormholeData.write(to: tempUrl)
            }
            catch {
                failure?(WormholeError.fileCachingError)
                return
            }
            
            // Add file transfer completion block
            self.fileTransfers[tempUrl.absoluteString] = { error in
                self.fileTransfers.removeValue(forKey: tempUrl.absoluteString)
                
                if error != nil {
                    failure?(WormholeError.sendingError(error!))
                }
            }
            
            // Prepare response listener
            let responseListener = DataListener { reply in
                if let response = T(data: reply) {
                    success?(response)
                }
                else {
                    failure?(.responseSerializationFailure)
                }
                
                return nil
            }
            responseListener.autoremoved = true
            self.addListener(responseListener, forIdentifier: tempUrl.absoluteString)
            
            // Send file
            session.transferFile(tempUrl, metadata: nil)
        }
    }
    
    // MARK: - Helpers
    
    // MARK: - Activation
    func activate() {
        if session == nil {
            session = sessionType.main()
            session?.delegate = self
            session?.activate()
        }
    }
    
    func invalidate() {
        session?.delegate = nil
        session = nil
    }
    
    // MARK: - Constants
    internal struct Key {
        static let Identifier = "identifier"
        static let Body = "body"
        static let FileTransferName = "fileTransferName"
    }
    internal struct DataSize {
        static let Byte         = 1
        static let KiloByte     = 1024 * DataSize.Byte
        static let MegaByte     = 1024 * DataSize.KiloByte
        static let MessageSize  = 60 * DataSize.KiloByte
    }
    
}

// MARK: - WCSessionDelegate
extension Wormhole: WCSessionDelegate {
    
    #if os(iOS)
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        invalidate()
    }
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        invalidate()
    }
    #endif
    
    @available(iOS 9.3, *)
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.session = session
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // TODO: handle reachability issues
        if session.isReachable {
            self.session = session
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] {
            let _ = listener.deliver(message[Key.Body] as AnyObject?)
        }
        else {
            // TODO: Handle
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] {
            let reply = listener.deliver(message[Key.Body])
            
            if let replyDict = reply as? BlackholeMessage {
                replyHandler(replyDict)
            }
            else {
                replyHandler([:])
            }
        }
        else {
            replyHandler([:])
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? BlackholeMessage else {
            // TODO: Handle!
            return
        }
        
        if let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] {
            let _ = listener.deliver(message[Key.Body])
        }
        else {
            // TODO: Handle!
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping ((Data) -> Void)) {
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [String:AnyObject] else {
            // TODO: Handle!
            replyHandler(Data())
            return
        }
        
        if let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] {
            let reply = listener.deliver(message[Key.Body])
            
            if let replyData = reply as? Data {
                replyHandler(replyData)
            }
            else {
                // TODO: Handle!
                replyHandler(Data())
            }
        }
        else {
            // TODO: Handle!
            replyHandler(Data())
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // Defer file clearup
        defer {
            do {
                try FileManager.default.removeItem(at: file.fileURL) // Remove file
            }
            catch {
                // TODO: Handle!
            }
        }
        
        // Retreive message data
        guard let messageData = try? Data(contentsOf: file.fileURL) else {
            // TODO: Handle!
            return
        }
        
        // Unarchive message
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [String:AnyObject] else {
            // TODO: Handle!
            return
        }
        
        // Retreive message identifier
        guard let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] else {
            // TODO: Handle!
            return
        }
        
        // Deliver message body
        let reply = listener.deliver(message[Key.Body])
        
        // If has file transfer name - means that waiting for transfer reply
        guard let transferIdentifier = message[Key.FileTransferName] as? String else {
            return
        }
        
        // Confirm reply data
        guard let replyData = reply as? Data else {
            return
        }
        
        // Send reply data
        do {
            try self.sendObject(replyData, withIdentifier: transferIdentifier, success: nil, failure: nil)
        }
        catch {
            // TODO: Handle
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // Complete transfer
        let blackholeError: WormholeError? = error != nil ? WormholeError.sendingError(error!) : nil
        self.fileTransfers[fileTransfer.file.fileURL.absoluteString]?(blackholeError)
        
        do {
            try FileManager.default.removeItem(at: fileTransfer.file.fileURL)
        }
        catch {
            // TODO: Handle!
        }
    }
    
}
