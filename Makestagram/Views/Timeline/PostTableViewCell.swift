//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Veronica Tan on 28/6/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesIconImageView: UIImageView!
    
    /*
     var post: Post? {
     didSet {
     // 1
     if let post = post {
     //2
     // bind the image of the post to the 'postImage' view
     post.image.bindTo(postImageView.bnd_image)
     }
     }
     }
     */
    
    var post: Post? {
        didSet {
            // 1
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                // 2
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    // 3
                    if let value = value {
                        // 4
                        self.likesLabel.text = self.stringFromUserList(value)
                        // 5
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        // 6
                        self.likesIconImageView.hidden = (value.count == 0)
                    } else {
                        // 7
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    
    /*
     
     1. We use the disposables to destroy any old bindings that may exist. This way we can avoid the situation in which this cell listens to updates from old posts that it's no longer displaying.
     2. Here we set up the bindings to post.image and post.likes. Notice that we assign the disposables to properties. This will allow us to destroy the bindings later. The binding to post.image is the same as it was before; it uses the bindTo method. However, to set up the binding to the likes of the post we use the observe method. The observe method is provided by the Bond framework and can be called on any object wrapped in the Observable type. observe takes one parameter, a closure (defined as a trailing closure in the code above), which in our case has type [PFUser]? -> (). The code defined by the closure will be executed every time post.likes receives a new value. The parameter named value in the closure definition will contain the actual contents of post.likes; that is, the Observable wrapper will have been removed.
     3. Because post.likes contains an optional array of PFUsers, we use optional binding to ensure that value is not nil.
     4. If we have received a value, we perform different updates. First of all we update the likesLabel to display a list of usernames of all users that have liked the post. We use a utility method stringFromUserList to generate that list. We'll add and discuss that method later when we implement it!
     5.  Next we set the state of the like button (the heart) based on whether or not the current user is in the list of users that like the currently displayed post. If the user has liked the post, we want the button to be in the Selected state so that the heart appears red. If not selected will be set to false and the heart will be displayed in gray.
     6. Finally, if no one likes the current post, we want to hide the small heart icon displayed in front of the list of users that like a post.
     7. We reach this code block if post.likes is nil. That happens if we're waiting on a response from Parse, but haven't received it yet. So we set all UI elements to default values.
     
     */
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }
    
    /*
   1.  You have already seen and used map before. As we discussed it allows you to replace objects in a collection with other objects. Typically you use map to create a different representation of the same thing. In this case we are mapping from PFUser objects to the usernames of these PFObjects.
   2. We now use that array of strings to create one joint string. We can do that by using the joinWithSeparator method provided by Swift. The joinWithSeparator method can be called on any array of strings. After the method is called, we have created a string of the following form: "Test User 1, Test User 2".
     */
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
}

/*
 
 1. Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil.
 2. If the value isn't nil, we create a binding between the image property of the post and the image property of the postImageView using the .bindTo method.
 -- Now our PostTableViewCell is able to receive and store a Post object and react to an asynchronously available image of that post!
 */