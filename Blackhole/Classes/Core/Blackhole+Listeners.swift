//
//  WormholeListeners.swift
//  GolfKeeper
//
//  Created by Andrzej Michnia on 21/08/16.
//  Copyright © 2016 yeslogo. All rights reserved.
//

import Foundation
import WatchConnectivity

// MARK: - Listener protocol
public protocol Listener: class {
    var time: Date { get }
    weak var wormhole: Wormhole? { get set }
    func deliver(_ object: Any?) -> Any?
}

// MARK: - Default count of timeout value
extension Listener {
    var timeoutValue: TimeInterval { return abs(self.time.timeIntervalSinceNow) }
}

// MARK: - Message Listener
public class MessageListener: Listener {
    
    // MARK: - Properties
    public let time = Date()
    var handler: (BlackholeMessage)->(BlackholeMessage?)
    var autoremoved: Bool = false
    weak public var wormhole: Wormhole?
    
    public init(handler: @escaping (BlackholeMessage)->(BlackholeMessage?)) {
        self.handler = handler
    }
    
    public func deliver(_ object: Any?) -> Any? {
        if self.autoremoved {
            self.wormhole?.removeListener(self)
        }
        
        guard let message = object as? BlackholeMessage else {
            return nil
        }
        
        return self.handler(message)
    }
    
}

// MARK: - Data listener
public class DataListener: Listener {
    
    // MARK: - Properties
    public let time = Date()
    var handler: (Data)->(Data?)
    var autoremoved: Bool = false
    weak public var wormhole: Wormhole?
    
    // MARK: - Lifecycle
    public init(handler: @escaping (Data)->(Data?)) {
        self.handler = handler
    }
    
    // MARK: - Public
    public func deliver(_ object: Any?) -> Any? {
        if self.autoremoved {
            self.wormhole?.removeListener(self)
        }
        
        guard let data = object as? Data else {
            // TODO: Handle!
            return nil
        }
        
        return self.handler(data)
    }
    
}
