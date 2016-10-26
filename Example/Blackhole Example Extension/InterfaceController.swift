//
//  InterfaceController.swift
//  Blackhole Example Extension
//
//  Created by Andrzej Michnia on 25.10.2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import Blackhole

class InterfaceController: WKInterfaceController {
    // MARK: - Outlets
    
    // MARK: - Properties
    var blackhole = Blackhole()
    
    // MARK: - Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
