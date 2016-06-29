//
//  Post.swift
//  Makestagram
//
//  Created by Veronica Tan on 28/6/16.
//  Copyright © 2016 Make School. All rights reserved.
//
/*
 
 1. To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
 2. Next, define each property that you want to access on this Parse class. For our Post class that's the user and the imageFile of a post. That will allow you to change the code that accesses properties through strings post["imageFile"] = imageFile into code that uses Swift properties post.imageFile = imageFile. Notice that we prefixed the properties with @NSManaged. This tells the Swift compiler that we won't initialize the properties in the initializer, because Parse will take care of it for us.
 3. By implementing the parseClassName static function, you create a connection between the Parse class and your Swift class.
 4. init and initialize are purely boilerplate code - copy these two into any custom Parse class that you're creating.
 */

import Foundation
import Parse


// 1 Need to inherit from PFObject and implmenet the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    var image: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    // 2 Define each property to access on this Parse class ---@NSManaged tells the compiler that properties will be initialized in Parse
    
    @NSManaged var imageFile: PFFile? //image file
    @NSManaged var user: PFUser? //user
    
    
    //MARK: PFSubclassing Protocol
    
    // 3 the parseClassName static function creates a connection between the Parse class and the Swift class
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4 --- the following should be copied into any parse class being created
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    /*
     1. When the uploadPost method is called, we grab the photo to be uploaded from the image property; turn it into a PFFile called imageFile.
     2. We assign imageFile to self.imageFile. Then we call saveInBackground() to upload the Post.*/
    
    /* func uploadPost() {
        if let image = image {
            // 1
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let imageFile = PFFile(name: "image.jpg", data: imageData)!
            
            // 2
            self.imageFile = imageFile
            saveInBackground()
        }
    } */
    
    /* func uploadPost() {
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            // any uploaded post should be associated with the current user
            user = PFUser.currentUser()
            self.imageFile = imageFile
            saveInBackgroundWithBlock(nil)
        }
    }*/
    
    func uploadPost() {
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            // any uploaded post should be associated with the current user
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            // 1
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            // 2
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                // 3
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
}
