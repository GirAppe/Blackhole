//
//  ViewController.swift
//  Blackhole
//
//  Created by Andrzej Michnia on 10/20/2016.
//  Copyright (c) 2016 Andrzej Michnia. All rights reserved.
//

import UIKit
import Blackhole

class ViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catNameTextField: UITextField!
    @IBOutlet weak var catBreedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sendCatButton: UIButton!
    
    // MARK: - Properties
    var blackhole = Blackhole()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Actions
    @IBAction func sendCatAction(_ sender: AnyObject) {
    }
    
    // MARK: - Navigation

}

