//
//  BlackholeError.swift
//  Pods
//
//  Created by Andrzej Michnia on 20.10.2016.
//
//

import Foundation

// MARK: - Wormhole Errors
public enum WormholeError: Error {
    case unknown
    case unknownResponse(Any?)
    case fileCachingError
    case invalidData
    case sendingError(Error)
    case responseSerializationFailure
    case sessionInactive
    case notReachable
}
