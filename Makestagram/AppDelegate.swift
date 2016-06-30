//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    // Set up the Parse SDK
    let configuration = ParseClientConfiguration {
        $0.applicationId = "makestagram"
        $0.server = "https://makestagram-parse-vee.herokuapp.com/parse"
    }
    Parse.initializeWithConfiguration(configuration)
    
    do {
        try PFUser.logInWithUsername("test", password: "test") //programatically sign in
    } catch {
        print("Unable to log in")
    }
    //We use an optional binding (if let user = PFUser.currentUser()) to check if the result of the method call was a PFUser.
    if let currentUser = PFUser.currentUser() { //this method returns an optional PFUser?
        print("\(currentUser.username!) logged in successfully") //unwrapped
    } else {
        print("No logged in user :(") //returns nil
    }

    //Now every new Parse object will be equipped with public read access and write access that is limited to the object's creator.
    
    let acl = PFACL()
    acl.publicReadAccess = true
    PFACL.setDefaultACL(acl, withAccessForCurrentUser: true) //Only current user can edit
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

