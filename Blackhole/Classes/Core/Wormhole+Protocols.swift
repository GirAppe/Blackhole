//
//  WormholeProtocols.swift
//  GolfKeeper
//
//  Created by Andrzej Michnia on 21/08/16.
//  Copyright © 2016 yeslogo. All rights reserved.
//

import Foundation
import WatchConnectivity

// MARK: - Protocols
protocol WormholeMessageMappable {
    init?(message: [String : AnyObject])
}

protocol WormholeMessageConvertible {
    func messageRepresentation() -> BlackholeMessage
}

protocol WormholeDataMappable {
    init?(data: Data)
}

protocol WormholeDataConvertible {
    func dataRepresentation() -> Data
}

// MARK: - Default extensions - WormholeDataConvertible
extension Data: WormholeDataConvertible {
    func dataRepresentation() -> Data {
        return self
    }
}

extension NSArray: WormholeDataConvertible {
    func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension NSDictionary: WormholeDataConvertible {
    func dataRepresentation() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension Array: WormholeDataConvertible {
    
    func dataRepresentation() -> Data {
        let anySelf = self.mapExisting { $0 }
        return NSArray(array: anySelf).dataRepresentation()
    }
    
}

// MARK: - Default extensions - WormholeMessageMappable
extension Dictionary: WormholeMessageMappable {
    
    init?(message: [String : AnyObject]){
        self.init()
        
        for key in message.keys {
            self[(key as! Key)] = (message[key]!) as? Value
        }
    }
    
}

// MARK: - Default extensions - WormholeDataMappable
extension Data: WormholeDataMappable {

    init?(data: Data) {
        self.init(data)
    }
    
}

extension Dictionary: WormholeDataMappable {
    
    // Only works for dictionaries as [string:AnyObject]
    init?(data: Data) {
        guard let nsmessage = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary else {
            return nil
        }
        
        guard let message = nsmessage as? [String : AnyObject] else {
            return nil
        }
        
        self.init(message: message)
    }
    
}

extension UIImage: WormholeDataMappable { }

extension Array: WormholeDataMappable {
    
    init?(data: Data) {
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

