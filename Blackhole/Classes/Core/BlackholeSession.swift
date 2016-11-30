//
//  BlackholeSession.swift
//  Pods
//
//  Created by Andrzej Michnia on 21.10.2016.
//
//

import Foundation
import WatchConnectivity

public protocol BlackholeSession: class {
    static func isSupported() -> Bool
    static func `main`() -> BlackholeSession
    
    weak var delegate: WCSessionDelegate? { get set}
    
    func activate()

    var isReachable: Bool { get }
    
    func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?)
    func sendMessageData(_ data: Data, replyHandler: ((Data) -> Swift.Void)?, errorHandler: ((Error) -> Swift.Void)?)
    func transferFile(_ file: URL, metadata: [String : Any]?) -> WCSessionFileTransfer
    
}

extension WCSession: BlackholeSession {
    
    public static func main() -> BlackholeSession {
        return WCSession.default()
    }
    
}
