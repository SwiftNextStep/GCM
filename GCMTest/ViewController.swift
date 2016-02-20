//
//  ViewController.swift
//  GCMTest
//
//  Created by Icaro Lavrador on 19/02/16.
//  Copyright © 2016 Icaro Lavrador. All rights reserved.
//

import UIKit
import Google

class ViewController: UIViewController {
    
    @IBOutlet weak var buttonOutlet: UIButton!
    var appDelegate: AppDelegate!
    var registrationOptions = [String: AnyObject]()
    var apnsToken: NSData!
    var token:String = ""

    @IBAction func buttonAction(sender: AnyObject) {
        registerForNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveApnsToken:", name: appDelegate.apnsResgistrationKey, object: nil)
    }
    
    func saveApnsToken(notification: NSNotification){
        if let info = notification.userInfo as? Dictionary<String, NSData>{
            if let deviceToken = info["deviceToken"]{
                apnsToken = deviceToken
                buttonOutlet.enabled = true
            } else{
                print("Could not find key deviceToken")
            }
        } else{
            print("Could not decode userInfo")
        }
    }
    
    func registerForNotification(){
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = appDelegate
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:apnsToken, kGGLInstanceIDAPNSServerTypeSandboxOption: true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(appDelegate.senderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: resgistrationHandler)
    }
    
    func resgistrationHandler(registrarionToken: String!, error:NSError!){
        if error == nil{
            token = registrarionToken
            print("Register with token \(token)")
            register()
        } else{
            print("Error registering for notification with message \(error.localizedDescription)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func register(){
        registerWithAppServer()
    }
    
    func registerWithAppServer(){
        let message = ["action": "register_new_client", "registration_token":token, "stringIdentifier":"Icaro"]
        sendMessage(message)
        subscribeToTopic()

    }
    
    func sendMessage(message: NSDictionary){
        let nextMessageID = NSDate().timeIntervalSince1970.description
        let to = appDelegate.senderID! + "@gcm.googleapis.com"
        GCMService.sharedInstance().sendMessage(message as [NSObject: AnyObject], to: to, withId: nextMessageID)
        print("------> message sent: \(message)")
    }
    
    func subscribeToTopic(){
        let topic = "/topics/IcaroTest"
        GCMPubSub.sharedInstance().subscribeWithToken(token, topic: topic, options: nil) { (error) -> Void in
            if error != nil{
                if error.code == 3001{
                    print("User already subscribe to this topic: \(topic)")
                } else{
                    print("Subscription fail with message \(error.localizedDescription)")
                }
            } else{
                print("User is now suscsbrided to topic \(topic)")
            }
            self.createMessage()
        }
    }
    
    func createMessage(){
        let message = ["message":"Hello GCM"]
        sendMessage(message)
    }
    
    
}

