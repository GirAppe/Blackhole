//
//  Array+MapExisting.swift
//  Pods
//
//  Created by Andrzej Michnia on 20.10.2016.
//
//

import Foundation

// MARK: - Array convenience map extended
internal extension Array {
    
    /**
     Works like map - but ommits nil values. Returns new Array containing of these mapping results, which returned non nil values.
     
     - parameter transform: Mapping closure
     
     - throws: Error of mapping if provided in closure
     
     - returns: Array containing of these mapping results, which returned non nil values
     */
    internal func mapExisting<T>(transform: (Array.Iterator.Element) throws -> T?) rethrows -> [T] {
        return try self.reduce([T]()) { (array, element) -> [T] in
            if let mappedElement = try transform(element) {
                return array + [mappedElement]
            }
            else {
                return array
            }
        }
    }
}
