//
//  Blackhole.swift
//  Pods
//
//  Created by Andrzej Michnia on 20.10.2016.
//
//

import Foundation
import WatchConnectivity

// MARK: - Wormhole
class Wormhole: NSObject {
    
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
    
    // MARK: - Private Properties
    internal var session: WCSession?
    internal var listeners: [String:Listener] = [:]             // Listener handlers
    internal var fileTransfers: [String:((NSError?)->())] = [:] // File transfer finished handlers - clearup and notify sending success
    
    // MARK: - Lifecycle
    override init(){
        super.init()
        
        self.activate()
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
        guard let session = session else {
            throw WormholeError.sessionInactive
        }
        
        if #available(iOS 9.3, *) {
            guard session.activationState == .activated else {
                throw WormholeError.sessionInactive
            }
        }
        
        guard session.isReachable else {
            throw WormholeError.notReachable
        }
        
        
        // TODO: Handle!
//        let _ = self.promiseSendMessage(message, withIdentifier: identifier)
    }
    
    // MARK: - Helpers
    func activate() {
        if session == nil {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
    }
    
}

// MARK: - WCSessionDelegate
extension Wormhole: WCSessionDelegate {
    
    #if os(iOS)
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        self.session?.delegate = nil
        self.session = nil
    }
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        self.session?.delegate = nil
        self.session = nil
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
            
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] {
            let reply = listener.deliver(message[Key.Body] as AnyObject?)
            
            if let replyDict = reply as? [String:AnyObject] {
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
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [String:AnyObject] else {
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
        defer {
            do {
                try FileManager.default.removeItem(at: file.fileURL) // Remove file
            }
            catch {
                // TODO: Handle!
            }
        }
        
        guard let messageData = try? Data(contentsOf: file.fileURL) else {
            // TODO: Handle!
            return
        }
        
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? [String:AnyObject] else {
            // TODO: Handle!
            return
        }
        
        guard let identifier = message[Key.Identifier] as? String, let listener = self.listeners[identifier] else {
            // TODO: Handle!
            return
        }
        
        let reply = listener.deliver(message[Key.Body])
        
        // If has file transfer name - means that waiting for transfer reply
        guard let transferIdentifier = message[Key.FileTransferName] as? String else {
            return
        }
        
        guard let replyData = reply as? Data else {
            return
        }
        
        if replyData.count < Wormhole.DataSize.MessageSize {
            // TODO: Handle!
//            let _ = self.promiseSendObject(replyData, withIdentifier: transferIdentifier)
        }
        else {
            // TODO: Handle!
//            let _ = self.promiseSendObjectAsFile(replyData, withIdentifier: transferIdentifier)
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // Complete transfer
        self.fileTransfers[fileTransfer.file.fileURL.absoluteString]?(error as NSError?)
        
        do {
            try FileManager.default.removeItem(at: fileTransfer.file.fileURL)
        }
        catch {
            // TODO: Handle!
        }
    }
    
}
