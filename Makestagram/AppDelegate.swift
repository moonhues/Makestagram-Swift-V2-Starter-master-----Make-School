//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                // 1
                ErrorHandling.defaultErrorHandler(error)
            } else  if let _ = user {
                // if login was successful, display the TabBarController
                // 2
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController")
                // 3
                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
            }
        }
    }
    
    /*
     In case we receive an error in our closure, we call the ErrorHandling.defaultErrorHandler method. This error handler method was included as part of the template project. It displays a popup with the error message. We'll discuss error handling in more detail later.
     If we didn't receive an error, but instead received a user, we know that our log in was successful. In this case, we load Main.storyboard and create the TabBarController. This is the line in which we use the Storyboard ID that we set up earlier. Before we removed Main.storyboard as the default entry point to our app, all of this was magically happening under the hood. Now we have to load storyboards and view controllers manually.
     After we have loaded the view controller, we are also responsible for presenting it. We can choose the main view controller of our app, in code, by setting the rootViewController property of the AppDelegate's window. When the code in this closure runs, our app will already have the login screen as its rootViewController. As soon as the successful login completes, we present the TabBarController on top of the login screen.
     */
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up the Parse SDK
        let configuration = ParseClientConfiguration {
            $0.applicationId = "makestagram"
            $0.server = "https://makestagram-parse-vee.herokuapp.com/parse"
        }
        Parse.initializeWithConfiguration(configuration)
        
        /* to be replaced by actual login capability
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
         */
        
        //Now every new Parse object will be equipped with public read access and write access that is limited to the object's creator.
        
        let acl = PFACL()
        acl.publicReadAccess = true
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true) //Only current user can edit
        
        //MARK Initializa Facebook
        
        // Initialize Facebook
        // 1
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // check if we have logged in user
        // 2
        let user = PFUser.currentUser()
        
        let startViewController: UIViewController
        
        if (user != nil) {
            // 3
            // if we have a user, set the TabBarController to be the initial view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        } else {
            // 4
            // Otherwise set the LoginViewController to be the first
            let loginViewController = PFLogInViewController()
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .Facebook]
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            
            startViewController = loginViewController
        }
        
        // 5
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
        //
        
        /*
         1. We start of by initializing the PFFacebookUtils - this is boilerplate code once again.
         2. We check whether or not a user is currently logged in.
         3. If a user is logged in, we load the TabBarControlller, just as we did in the closure of the ParseLoginHelper, and let the user jump directly to the timeline.
         4. If we don't have a user, we need to present the Login View Controller. We create one, using the PFLoginViewController provided by Parse. The component allows for some customization, you can read the details here. We also set the parseLoginHelper as the delegate of the PFLoginViewController. The ParseLoginHelper will be notified about logins and signups by the PFLoginViewController. It will then forward the information to us by calling the closure that we defined when creating the ParseLoginHelper.
         5. The last step is creating the UIWindow for our application. That's the container for all the views in our app. We then display the startViewController as the rootViewController of the app. Depending on whether we had a logged in user or not, this will be the TabBarViewController or the PFLoginViewController
         */
        
        // return true - replaced with one below, part of FB boilerplate code
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
    
    /* Replaced with the boilerplate FB code below
     func applicationDidBecomeActive(application: UIApplication) {
     // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     } */
    
    //MARK: Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

