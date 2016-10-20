//
//  BlackholeError.swift
//  Pods
//
//  Created by Andrzej Michnia on 20.10.2016.
//
//

import Foundation

// MARK: - Wormhole Errors
enum WormholeError: Error {
    case unknown
    case unknownResponse(Any?)
    case invalidData
    case sendingError(Error)
    case sessionInactive
    case notReachable
}
