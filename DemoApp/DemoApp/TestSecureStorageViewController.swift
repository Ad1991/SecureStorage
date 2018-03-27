//
//  TestSecureStorageViewController.swift
//  DemoApp
//
//  Created by Adarsh Kumar Rai on 26/03/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import SecureStorage

class TestSecureStorageViewController: UIViewController {
    
    var keychainSharingEnabled = false
    var appGroupEnabled = false
    var shouldUseFile = false
    
    let keyForStorage = "some_key_to_store_text"
    
    @IBOutlet weak var textViewToStore: UITextView!
    @IBOutlet weak var retrievedTextView: UITextView!
    
    
    var secureStorage: SecureStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Secure Storage Test"
        
        if !keychainSharingEnabled && !appGroupEnabled && !shouldUseFile {
            secureStorage = SecureStorage(keychainAccessGroup: nil)
        } else if keychainSharingEnabled && !appGroupEnabled && !shouldUseFile {
            secureStorage = SecureStorage(keychainAccessGroup: keychainAccessGroup(for: Bundle.main))
        } else if keychainSharingEnabled && appGroupEnabled {
            //Let it crash if not able to initialize with shared defaults
            secureStorage = try! SecureStorage(sharedDefaultsId: "group.com.personal.SecureStorage.DemoApp", keychainAccessGroup: keychainAccessGroup(for: Bundle.main))
        } else if !keychainSharingEnabled && appGroupEnabled {
            //Let it crash if not able to initialize with shared defaults
            secureStorage = try! SecureStorage(sharedDefaultsId: "group.com.personal.SecureStorage.DemoApp", keychainAccessGroup: nil)
        } else if keychainSharingEnabled && shouldUseFile {
            //Let it crash if not able to initialize file storage
            secureStorage = try! SecureStorage(fileLocation: fileLocation, keychainAccessGroup: keychainAccessGroup(for: Bundle.main))
        } else if !keychainSharingEnabled && shouldUseFile {
            //Let it crash if not able to initialize file storage
            secureStorage = try! SecureStorage(fileLocation: fileLocation, keychainAccessGroup: nil)
        }
        
        textViewToStore.layer.borderColor = UIColor.gray.cgColor
        textViewToStore.layer.borderWidth = 0.5
        textViewToStore.layer.cornerRadius = 5.0
        
        retrievedTextView.layer.borderColor = UIColor.gray.cgColor
        retrievedTextView.layer.borderWidth = 0.5
        retrievedTextView.layer.cornerRadius = 5.0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func keychainAccessGroup(for bundle: Bundle) -> String {
        let appId = bundle.object(forInfoDictionaryKey: "AppIDPrefix") as! String
        return appId + "com.personal.SecureStorage.DemoApp"
    }
    
    
    lazy var fileLocation: String = {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        //Let is crash if path does not exist
        let filePath = documents! + "/SecureStorage"
        if !FileManager.default.fileExists(atPath: filePath) {
            //Let is crash if not able to create folder
            try! FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }
        return filePath
    }()
    

    @IBAction func storeText(_ sender: UIButton) {
        view.endEditing(true)
        do {
            try secureStorage.store(textViewToStore.text, for: keyForStorage)
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func retrieveText(_ sender: UIButton) {
        do {
            let text = try secureStorage.fetchObject(for: keyForStorage)
            retrievedTextView.text = text as! String
        } catch {
            print(error)
        }
    }
}
