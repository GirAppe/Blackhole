//
//  Cat.swift
//  Blackhole
//
//  Created by Andrzej Michnia on 30.11.2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Blackhole
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

class Cat: BlackholeDataMappable {
    let name: String
    let breed: String
    let image: UIImage
    
    init(name: String, breed: String, image: UIImage) {
        self.name = name
        self.breed = breed
        self.image = image
    }
    
    convenience required init?(data: Data) {
        guard let dictionary = NSDictionary.dictionary(withData: data) else {
            return nil
        }

        guard let name = dictionary["name"] as? String,
            let breed = dictionary["breed"] as? String,
            let imageData = dictionary["imageData"] as? Data,
            let image = UIImage(data: imageData)
        else {
            return nil
        }
        
        self.init(name: name, breed: breed, image: image)
    }
    
}

// MARK: - BlackholeDataConvertible
extension Cat: BlackholeDataConvertible {
    
    func dataRepresentation() -> Data {
        let dictionary = NSMutableDictionary()
        
        dictionary["name"] = self.name
        dictionary["breed"] = self.breed
        dictionary["imageData"] = self.image.dataRepresentation()
        
        return dictionary.dataRepresentation()
    }
    
}


