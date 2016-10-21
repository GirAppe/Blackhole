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
protocol Listener: class {
    var time: Date { get }
    weak var wormhole: Wormhole? { get set }
    func deliver(_ object: Any?) -> Any?
}

// MARK: - Default count of timeout value
extension Listener {
    var timeoutValue: TimeInterval { return abs(self.time.timeIntervalSinceNow) }
}

// MARK: - Message Listener
class MessageListener: Listener {
    
    // MARK: - Properties
    let time = Date()
    var handler: (BlackholeMessage)->(BlackholeMessage?)
    var autoremoved: Bool = false
    weak var wormhole: Wormhole?
    
    init(handler: @escaping (BlackholeMessage)->(BlackholeMessage?)) {
        self.handler = handler
    }
    
    func deliver(_ object: Any?) -> Any? {
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
class DataListener: Listener {
    
    // MARK: - Properties
    let time = Date()
    var handler: (Data)->(Data?)
    var autoremoved: Bool = false
    weak var wormhole: Wormhole?
    
    // MARK: - Lifecycle
    init(handler: @escaping (Data)->(Data?)) {
        self.handler = handler
    }
    
    // MARK: - Public
    func deliver(_ object: Any?) -> Any? {
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
