//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Veronica Tan on 26/6/16.
//  Copyright © 2016 Make School. All rights reserved.
//

/*
 import UIKit
 
 class TimelineViewController: UIViewController {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 // Do any additional setup after loading the view.
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 
 /*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
 
 }*/

import UIKit
import Parse
import ConvenienceKit


// class TimelineViewController: UIViewController {
class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    //you need to provide two different types in the angled brackets: the type of object you are displaying (Post) and the class that will be the target of the TimelineComponent
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self //setting TimelineViewController to tabBrController
    }*/
    
    
    /*func takePhoto() {
     // instantiate photo taking class, provide callback for when photo is selected
     
     photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
     // don't do anything, yet...
     print("received a callback")
     }
     }*/
    
    /*func takePhoto() {
     // instantiate photo taking class, provide callback for when photo is selected
     photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
     let post = Post()
     post.image = image
     post.uploadPost()
     }
     } */
    
    //Replaced above for to change to Observable property
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            // 1
            post.image.value = image! // Because image is now an Observable type, we need to store the image using the .value property. We need to append .value to access the value wrapped by the Observable
            post.uploadPost()
        }
    }
    
    /*
     1. First, we are creating the query that fetches the Follow relationships for the current user.
     2. We use that query to fetch any posts that are created by users that the current user is following.
     3. We create another query to retrieve all posts that the current user has posted.
     4. We create a combined query of the 2. and 3. queries using the orQueryWithSubqueries method. The query generated this way will return any Post that meets either of the constraints of the queries in 2. or 3.
     5. We define that the combined query should also fetch the PFUser associated with a post. As you might remember, we are storing a pointer to a user object in the user column of each post. By using the includeKey method we tell Parse to resolve that pointer and download all the information about the user along with the post. We will need the username later when we display posts in our timeline.
     6. We define that the results should be ordered by the createdAt field. This will make posts on the timeline appear in chronological order.
     7. We kick off the network request.
     8. In the completion block we receive all posts that meet our requirements. The Parse framework hands us an array of type [PFObject]?. However, we would like to store the posts in an array of type [Post]. In this step we check if it is possible to cast the result into a [Post]; if that's not possible (e.g. because the result is nil) we store an empty array ([]) in self.posts. The ?? operator is called the nil coalescing operator in Swift. If the statement before this operator returns nil, the return value will be replaced with the value after the operator.
     9. Once we have stored the new posts, we refresh the tableView.
     */
    
    /*
     override func viewDidAppear(animated: Bool) {
     super.viewDidAppear(animated)
     
     // 1 Find out all the users that the logged in user is following
     let followingQuery = PFQuery(className: "Follow")
     followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
     
     // 2 Fetch the posts created by the users logged in user is following
     let postsFromFollowedUsers = Post.query()
     postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
     
     // 3 Fetch all posts created by logged in user
     let postsFromThisUser = Post.query()
     postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
     
     // 4 Combo of 2 and 3 - combine results from 2 queries to combine both posts
     let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
     
     // 5 Get information of user who made the post
     query.includeKey("user")
     
     // 6 This will sort the results and show the latest post first
     query.orderByDescending("createdAt")
     
     /*// 7 Kickoff request
     query.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
     
     // 8 Results are returned in an array of posts
     self.posts = result as? [Post] ?? []
     
     // 9 refresh table view one all new posts are stored
     self.tableView.reloadData()
     } */
     
     query.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
     self.posts = result as? [Post] ?? []
     
     // 1 loop over all posts returned from the timeline
     for post in self.posts {
     do {
     // 2
     let data = try post.imageFile?.getData()
     // 3
     post.image = UIImage(data: data!, scale:1.0)
     } catch {
     print("could not get image")
     }
     }
     
     self.tableView.reloadData()
     }
     } */
    
    /*
     override func viewDidAppear(animated: Bool) {
     super.viewDidAppear(animated)
     
     ParseHelper.timelineRequestForCurrentUser {
     (result: [PFObject]?, error: NSError?) -> Void in
     self.posts = result as? [Post] ?? []
     
     for post in self.posts {
     do {
     let data = try post.imageFile?.getData()
     post.image = UIImage(data: data!, scale:1.0)
     } catch {
     print("could not get image")
     }
     }
     
     self.tableView.reloadData()
     }
     }
     
     //call ParseHelper.timelineRequestforCurrentUser and hand the method a completion block (which we are doing using the trailing closure syntax) -- Basically all queries are done in Parsehelper. A block of codes on handling the result of the queries is passed in to the mehthod.
     
     */
    //The following replaces the above to load images only when posts are displayed. In contrast, he above  downloads all images immediately after the timeline query completes
    
    /*
     
    // Since we have implemented the timeline query inside of the loadInRange method, we also no longer need it in the viewDidAppear method
     
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser { (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
            
            self.tableView.reloadData()
        }
    }
 */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
    }
    
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    /*
     func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
     if (viewController is PhotoViewController) {
     print("Take Photo")
     return false
     } else {      //if the user selects FriendSearh or Home
     return true
     }
     }*/
    
    //shouldSelectViewController tells
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool { //Asks the delegate whether the specified view controller should be made active
        if (viewController is PhotoViewController) {
            takePhoto() //no - want to display dialog
            return false
        } else {
            return true
        }
    }
}

/*
 1. Our Table View needs to have as many rows as we have posts stored in the posts property
 2. For now we return a simple placeholder cell with the title "Post"
 */

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineComponent.content.count
    }
    
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return posts.count
    }*/
    
    /* func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     // 2
     let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")!
     
     cell.textLabel!.text = "Post"
     
     return cell
     }*/
    
    /*
     1. In this line we cast cell to our custom class PostTableViewCell. (In order to access the specific properties of our custom table view cell, we need to perform a cast to the type of our custom class. Without this cast the cell variable would have a type of a plain old UITableViewCell instead of our PostTableViewCell.)
     2. Using the postImageView property of our custom cell we can now decide which image should be displayed in the cell.
     */
    
    /* func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     // 1
     let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
     
     // 2
     cell.postImageView.image = posts[indexPath.row].image
     
     return cell
     } */
    
    /*
     
     //The following method updated to trigger the image download for our visible posts.
     
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
     
     let post = posts[indexPath.row]
     // 1
     post.downloadImage()
     // 2
     cell.post = post
     
     return cell
     }
     
     /*
     1. Directly before a post will be displayed, we trigger the image download.
     2. Instead of changing the image that is displayed in the cell from within the 3. TimelineViewController, we assign the post that shall be displayed to the post property. After the changes we made a few steps back, the cell now takes care of displaying the image that belongs to a Post object itself.
     */
     */
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
    
    /*
    
    // Placed inside the cellForRowAtIndexPath method of the TimelineViewController. Why? Because that method gets called immediately before a cell gets displayed. Extend the method to look like this:
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = posts[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    } */
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
    /*
     
     1. We start by calling the timelineRequestForCurrentUser method. Earlier we extended the method to take a range parameter. Now we can simply pass the range that we received in the range argument.
     2.In the callback of the query we check whether or not we have received a result. If the result is nil we store an empty array in the posts variable.
     3. We pass the posts that have been loaded back to the TimelineComponent by calling the completionBlock.
     
     */
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}

