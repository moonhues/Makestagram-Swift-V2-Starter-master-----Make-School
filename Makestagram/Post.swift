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
import Bond


// 1 Need to inherit from PFObject and implmenet the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    //var image: UIImage?
    var image: Observable<UIImage?> = Observable(nil)
    
    /*Observable is a wrapper around the actual value that we want to store. That wrapper allows us to listen for changes to the wrapped value. The Observable wrapper enables us to use the property together with bindings */
    
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
    
    /* func uploadPost() {
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
     } */
    
    func uploadPost() { //Using the Observable image property
        
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    func downloadImage() { //Moved from TimelineViewController
        // if image is not downloaded yet, get it
        // 1
        if (image.value == nil) {
            // 2
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image
                }
            }
        }
    }
    
    /*
     1. First, we check if image.value already has a stored value. We do this to avoid downloading images multiple times. (We only want to start the donwload if image.value is nil.)
     2. Here we start the download. Instead of using getData we are using getDataInBackgroundWithBlock - that way we are no longer blocking the main thread!
     3. Once the download completes, we update the post.image. Note that we are now using the .value property, because image is an Observable.
     */
    
    func fetchLikes() {
        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            // 3
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    /*
     
     1.  First we are checking whether likes.value already has stored a value or is nil. If we've already stored a value, we will skip the entire method. As discussed, we will cache all likes until the entire timeline is refreshed (which we haven't implemented yet). So as soon as likes.value has a cached value, we don't need to perform the body of this method.
     2. We fetch the likes for the current Post using the ParseHelper likesForPost method that we created earlier
     3. There is a new concept on this line: the filter method that we call on our Array. The filter method takes a closure and returns an array that only contains the objects from the original array that meet the requirement stated in that closure. The closure passed to the filter method gets called for each element in the array, each time passing the current element as the like argument to the closure. Note that you can pick any arbitrary name for the argument that we called like. So why are we filtering the array in the first place? We are removing all likes that belong to users that no longer exist in our Makestagram app (because their account has been deleted). Without this filtering the next statement could crash.
     4. Here we are again using a new method: map. The map method behaves similarly to the filter method in that it takes a closure that is called for each element in the array and in that it also returns a new array as a result. The difference is that, unlike filter, map does not remove objects but replaces them. In this particular case we are replacing the likes in the array with the users that are associated with the like. We start with an array of likes and retrieve an array of users. Then we assign the result to our likes.value property.
     
     */
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    //check if a given user is contained in the array stored in the likes property.
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if post is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this post is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    /*
     
     1.If the toggleLikePost method is called and the user already likes the post, we unlike the post. First by removing the user from the local cache stored in the likes property, then by syncing the change with Parse. We remove the user from the local cache by using the filter method on the array stored in likes.value.
     2.If the user doesn't like the post yet, we add them to the local cache and then sync the change with Parse.
     */
}
