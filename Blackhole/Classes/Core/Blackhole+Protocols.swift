//
//  BlackholeProtocols.swift
//  GolfKeeper
//
//  Created by Andrzej Michnia on 21/08/16.
//  Copyright © 2016 yeslogo. All rights reserved.
//

import Foundation
import WatchConnectivity

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif
    
// MARK: - Typedefs
/// Accepts only plist type dictionaries
public typealias BlackholeMessage = [String:Any]
/// Default success closure
public typealias BlackholeSuccessClosure = ()->()
/// Default failure closure
public typealias BlackholeFailureClosure = (BlackholeError?)->()

// MARK: - Protocols
public protocol BlackholeMessageMappable {
    init?(message: BlackholeMessage)
}

public protocol BlackholeMessageConvertible {
    func messageRepresentation() -> BlackholeMessage
}

public protocol BlackholeDataMappable {
    init?(data: Data)
}

public protocol BlackholeDataConvertible {
    func dataRepresentation() -> Data
}

// MARK: - Default extensions - BlackholeDataConvertible
extension Data: BlackholeDataConvertible {
    public func dataRepresentation() -> Data {
        return self
    }
}

extension NSArray: BlackholeDataConvertible {
    public func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension NSDictionary: BlackholeDataConvertible {
    
    /// All objects must support NSArchiving / NSCoding
    ///
    /// - Returns: Data representation
    public func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension Array: BlackholeDataConvertible {
    public func dataRepresentation() -> Data {
        let anySelf = self.mapExisting { $0 }
        return NSArray(array: anySelf).dataRepresentation()
    }
}

extension UIImage: BlackholeDataConvertible {
    // By default sends image as PNG
    public func dataRepresentation() -> Data {
        return UIImagePNGRepresentation(self)!
    }
}

// MARK: - Default extensions - BlackholeMessageMappable
extension Dictionary: BlackholeMessageMappable {
    public init?(message: BlackholeMessage){
        self.init()
        
        for key in message.keys {
            self[(key as! Key)] = (message[key]!) as? Value
        }
    }
}

extension Dictionary: BlackholeMessageConvertible {
    public func messageRepresentation() -> BlackholeMessage {
        var message: BlackholeMessage = [:]
        
        if Key.self == String.self {
            self.keys.forEach { key in
                message[key as! String] = self[key]
            }
        }
        
        return message
    }
}

// MARK: - Default extensions - BlackholeDataMappable
extension Data: BlackholeDataMappable {
    public init?(data: Data) {
        self.init(data)
    }
}

extension Dictionary: BlackholeDataMappable {
    // Only works for dictionaries as [String:Any]
    public init?(data: Data) {
        guard let nsmessage = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary else {
            return nil
        }
        
        guard let message = nsmessage as? BlackholeMessage else {
            return nil
        }
        
        self.init(message: message)
    }
}

extension Array: BlackholeDataMappable {
    
    public init?(data: Data) {
        guard let nsarray = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSArray else {
            return nil
        }
        
        self.init()
        
        nsarray.forEach { object in
            if object is Element {
                self.append(object as! Element)
            }
        }
    }
    
}

extension UIImage: BlackholeDataMappable { }

// MARK: - Helpers
extension NSDictionary {
    
    public class func dictionary(withData data: Data) -> NSDictionary? {
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary else {
            return nil
        }
        
        return dict
    }
    
}

