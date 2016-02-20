//
//  AppDelegate.swift
//  GCMTest
//
//  Created by Icaro Lavrador on 19/02/16.
//  Copyright © 2016 Icaro Lavrador. All rights reserved.
//

import UIKit
import Google
import Google.CloudMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    var senderID: String?
    
    let apnsResgistrationKey = "onApnsResgistrationKey"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Config Google
        var error:NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        assert(error == nil, "Error configuring Google service, with message \(error?.localizedDescription)")
        senderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        //Register for remote notification
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        let config = GCMConfig.defaultConfig()
        config.receiverDelegate = self
        config.logLevel = GCMLogLevel.Debug
        GCMService.sharedInstance().startWithConfig(config)        
        return true
    }
    
    func onTokenRefresh() {
        print("Token needs refresh")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Register for remote notification with token \(deviceToken)")
        NSNotificationCenter.defaultCenter().postNotificationName(apnsResgistrationKey, object: nil, userInfo: ["deviceToken":deviceToken])
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Fail to register for remote notification with message \(error.localizedDescription)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification Received, didReceiveRemoteNotification")
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Notification Received, handler")
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);

    }
    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication){
        GCMService.sharedInstance().connectWithHandler { (error) -> Void in
            if error == nil{
                print("Connected to GCM")
            } else{
                print("Error connecting to GCM \(error.localizedDescription)")
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
     }
    
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if error != nil{
            print("Error \(error.localizedDescription)")
        } else{
            print("Will send messageID is \(messageID)")
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        print("Sent Message \(messageID)")
    }
    



}

