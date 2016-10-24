//
//  NSFIleManager+CacheFileUrl.swift
//  GolfKeeper
//
//  Created by Andrzej Michnia on 21/08/16.
//  Copyright © 2016 yeslogo. All rights reserved.
//

import Foundation

// MARK: - FileManager - cache file name generation
extension FileManager {
    
    /**
     Returns temporary url that can be used to store temporary cached file.
     
     - parameter fileType: file extensions (defaul is ".temp")
     
     - returns: File url in Cache directory, or nil
     */
    public class func cacheTemporaryFileUrl(_ fileType: String = ".temp") -> URL? {
        return FileManager.default.cacheTemporaryFileUrl(fileType)
    }
    
    /**
     Returns temporary url that can be used to store temporary cached file.
     
     - parameter fileType: file extensions (defaul is ".temp")
     
     - returns: File url in Cache directory, or nil
     */
    public func cacheTemporaryFileUrl(_ fileType: String = ".temp") -> URL? {
        let urls = self.urls(for: .cachesDirectory, in: .userDomainMask)
        
        guard let dir = urls.first else {
            return nil
        }
        
        let filename = UUID().uuidString + "\(fileType)"
        
        return URL(fileURLWithPath: filename, relativeTo: dir)
    }
    
}
