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
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var breedLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    
    // MARK: - Properties
    var blackhole = Blackhole()
    var counter = 0
    
    // MARK: - Lifecycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let textListener = MessageListener { (message) -> (BlackholeMessage?) in
            if let text = message["text"] as? String {
                DispatchQueue.main.async {
                    self.titleLabel.setText("\(text)")
                }
            }
            else {
                DispatchQueue.main.async {
                    self.titleLabel.setText("unknown message")
                }
            }
            return nil
        }
        
        let catListener = ObjectListener(type: Cat.self) { cat in
            DispatchQueue.main.async {
                self.nameLabel.setText(cat.name)
                self.breedLabel.setText(cat.breed)
                self.imageView.setImage(cat.image)
            }
        }
        
        blackhole.addListener(textListener, forIdentifier: "sendText")
        blackhole.addListener(catListener, forIdentifier: "sendCat")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.titleLabel.setText("ACTIVATIONS: \(counter)")
        counter += 1
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
