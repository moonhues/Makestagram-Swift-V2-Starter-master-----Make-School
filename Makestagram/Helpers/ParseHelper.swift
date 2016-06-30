//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Veronica Tan on 29/6/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

// 1
class ParseHelper {
    
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    /*
     static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
     let followingQuery = PFQuery(className: ParseFollowClass)
     followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
     
     let postsFromFollowedUsers = Post.query()
     postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
     
     let postsFromThisUser = Post.query()
     postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
     
     let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
     query.includeKey(ParsePostUser)
     query.orderByDescending(ParsePostCreatedAt)
     
     query.findObjectsInBackgroundWithBlock(completionBlock)
     }*/
    
    
    //modify the method signature to accept a Range argument
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        // 2
        query.skip = range.startIndex
        // 3
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /*
     
     1. As discussed, we modify the method signature to accept a Range argument. That Range argument will define which portions of the timeline will be loaded. Range literals can be defined like this: 5..10 (10 included) or 5..<10 (10 excluded).
     2. PFQuery provides a skip property. That allows us - as suspected by the name - to define how many elements that match our query shall be skipped. This is the equivalent of the startIndex of our range, so all we need to do is a simple assignment.
     3. We make use of an additional property of PFQuery: limit. The limit property defines how many elements we want to load. We calculate the size of the range (by subtracting the startIndex from the endIndex) and pass the result to the limit property.
     
     */
    
    //adding a like
    
    // MARK: Likes
    
    static func likePost(user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    // deleting a like
    
    static func unlikePost(user: PFUser, post: Post) {
        // 1
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            // 2
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    /*
     
     1. We build a query to find the like of a given user that belongs to a given post
     2. We iterate over all like objects that met our requirements and delete them.
     
     */
    
    //fetching all the likes
    // 1
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // 2
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /*
     1. That's the default signature for the callback of most Parse queries. It takes an optional result and an optional error. By taking this type of block as an argument, we can hand it directly to the findObjectsInBackgroundWithBlock method! This way, whoever has called the likesForPost method will get the results in the callback block that they provide.
     2. We are using the includeKey(_) method to tell Parse to fetch the PFUser object for each of the likes (we've discussed includeKey(_) in detail when building the timeline request). We want to fetch the PFUser along with the likes because later on we want to display the usernames of all users that have liked a post. Remember, without the includeKey(_) line, we would just have a reference to a PFUser and would have to start a separate request to fetch the information about the user.
     */
    
    /*
     // 2
     static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
     let followingQuery = PFQuery(className: "Follow")
     followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
     
     let postsFromFollowedUsers = Post.query()
     postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
     
     let postsFromThisUser = Post.query()
     postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
     
     let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
     query.includeKey("user")
     query.orderByDescending("createdAt")
     
     // 3
     query.findObjectsInBackgroundWithBlock(completionBlock)
     } */
    
    /*
     
     1.  We are going to wrap all of our helper methods into a class called ParseHelper. We only do this so that all of the functions are bundled under the ParseHelper namespace. That makes the code easier to read in some cases. To call the timeline request function you call ParseHelper.timelineRequestforUser... instead of simply timelineRequestforUser. That way you always know exactly in which file you can find the methods that are being called.
     
     2. We mark this method as static. This means we can call it without having to create an instance of ParseHelper - you should do that for all helper methods. This method has only one parameter, completionBlock: the callback block that should be called once the query has completed. The type of this parameter is PFQueryArrayResultBlock. That's the default type for all of the callbacks in the Parse framework. By taking this callback as a parameter, we can call any Parse method and return the result of the method to that completionBlock - you'll see how we use that in 3.
     
     3. The entire body of this method is unchanged, it's the exact timeline query that we've built within the TimelineViewController. The only difference is the last line of the method. Instead of providing a closure and handling the results of the query within this method, we hand off the results to the closure that has been handed to use through the completionBlock parameter. This means whoever calls the timelineRequestForCurrentUser method will be able to handle the result returned from the query!
     */
    
    //Now Swift knows to consider any two Parse objects equal if they have the same objectId.
    
}

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}
