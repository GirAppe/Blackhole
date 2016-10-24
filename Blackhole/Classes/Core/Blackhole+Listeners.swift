//
//  BlackholeListeners.swift
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
    weak var wormhole: Blackhole? { get set }
    func deliver(_ object: Any?) -> Any?
}

// MARK: - Default count of timeout value
extension Listener {
    var timeoutValue: TimeInterval { return abs(self.time.timeIntervalSinceNow) }
}

// MARK: - Message Listener
open class MessageListener: Listener {
    
    // MARK: - Properties
    open let time = Date()
    var handler: (BlackholeMessage)->(BlackholeMessage?)
    var autoremoved: Bool = false
    weak open var wormhole: Blackhole?
    
    public init(handler: @escaping (BlackholeMessage)->(BlackholeMessage?)) {
        self.handler = handler
    }
    
    open func deliver(_ object: Any?) -> Any? {
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
open class DataListener: Listener {
    
    // MARK: - Properties
    open let time = Date()
    var handler: (Data)->(Data?)
    var autoremoved: Bool = false
    weak open var wormhole: Blackhole?
    
    // MARK: - Lifecycle
    public init(handler: @escaping (Data)->(Data?)) {
        self.handler = handler
    }
    
    // MARK: - Public
    open func deliver(_ object: Any?) -> Any? {
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

open class ObjectListener<T:BlackholeDataMappable>: Listener {
    
    // MARK: - Properties
    open let time = Date()
    var handler: ((T)->(BlackholeDataConvertible?))?
    private var voidHandler: ((T)->(Void))?
    var autoremoved: Bool = false
    weak open var wormhole: Blackhole?
    
    // MARK: - Lifecycle
    public init<R:BlackholeDataConvertible>(type: T.Type, responseType: R.Type, handler: @escaping (T)->(R?)) {
        self.handler = handler
    }
    public init(type: T.Type, handler: @escaping (T)->()) {
        self.voidHandler = handler
    }
    
    // MARK: - Public
    open func deliver(_ object: Any?) -> Any? {
        if self.autoremoved {
            self.wormhole?.removeListener(self)
        }
        
        guard let data = object as? Data else {
            return nil
        }
        
        guard let object = T(data: data) else {
            return nil
        }

        if let handler = self.handler {
            return handler(object)
        }
        else {
            self.voidHandler?(object)
            return nil
        }
    }
    
}
