//
//  ViewController.swift
//  Blackhole
//
//  Created by Andrzej Michnia on 10/20/2016.
//  Copyright (c) 2016 Andrzej Michnia. All rights reserved.
//

import UIKit
import Blackhole

enum CatBreed : String {
    case bengal = "bengal"
    case persian = "persian"
    case siamese = "siamese"
    
    var image: UIImage {
        switch self {
        case .bengal:
            return #imageLiteral(resourceName: "bengal")
        case .persian:
            return #imageLiteral(resourceName: "persian")
        case .siamese:
            return #imageLiteral(resourceName: "siamese")
        }
    }
}

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
    
    // MARK: - Private
    private func validate() -> Bool {
        return (catNameTextField.text?.characters.count ?? 0) > 0
    }
    
    private func revalidate() {
        sendCatButton.isEnabled = validate()
    }
    
    private func breed() -> CatBreed? {
        switch catBreedSegmentedControl.selectedSegmentIndex {
        case 0:
            return .bengal
        case 1:
            return .persian
        case 2:
            return .siamese
        default:
            return nil
        }
    }
    
    // MARK: - Actions
    @IBAction func nameChangedAction(_ sender: UITextField) {
        revalidate()
    }
    
    @IBAction func nameEditEndedAction(_ sender: UITextField) {
        revalidate()
    }
    
    @IBAction func catBreedSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            catImageView.image = CatBreed.bengal.image
        case 1:
            catImageView.image = CatBreed.persian.image
        case 2:
            catImageView.image = CatBreed.siamese.image
        default:
            break
        }
    }
    
    @IBAction func sendCatAction(_ sender: AnyObject) {
        guard let name = catNameTextField.text, let breed = breed()?.rawValue, let image = catImageView.image else {
            return
        }
        
        let cat = Cat(name: name, breed: breed, image: image)
        
//        blackhole.promiseSendMessage(["text":"cat \(cat.name)"], withIdentifier: "sendText")
        blackhole.promiseSendObject(cat, withIdentifier: "sendCat")
        .onSuccess {
            print("SUCCESS SENDING!")
        }
        .onFailure { error in
            print("ERROR: \(error)")
        }
    }
    
    @IBAction func dismissKeyboardAction(_ sender: Any) {
        catNameTextField.resignFirstResponder()
        revalidate()
    }
    
    // MARK: - Navigation
    
}

