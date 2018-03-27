//
//  ViewController.swift
//  DemoApp
//
//  Created by Adarsh Kumar Rai on 23/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var keychainSharingSwitch: UISwitch!
    @IBOutlet weak var appGroupSwitch: UISwitch!
    @IBOutlet weak var fileStorageSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Secure Storage Config"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier, segueID == "launchTestScreen" {
            let testViewController = segue.destination as! TestSecureStorageViewController
            testViewController.keychainSharingEnabled = keychainSharingSwitch.isOn
            testViewController.appGroupEnabled = appGroupSwitch.isOn
            testViewController.shouldUseFile = fileStorageSwitch.isOn
        }
    }
    

    @IBAction func enableAppGroup(_ sender: UISwitch) {
        if sender.isOn {
            fileStorageSwitch.isOn = false
        }
    }
    
    
    @IBAction func enableFileStorage(_ sender: UISwitch) {
        if sender.isOn {
            appGroupSwitch.isOn = false
        }
    }
    
}

