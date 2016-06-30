//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Veronica Tan on 30/6/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

/*
 class FriendSearchTableViewCell: UITableViewCell {
 
 @IBOutlet weak var usernameLabel: UILabel!
 @IBOutlet weak var followButton: UIButton!
 @IBAction func followButtonTapped(sender: AnyObject) {
 }
 
 }
 
 import UIKit
 import Parse
 
 protocol FriendSearchTableViewCellDelegate: class {
 func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
 func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
 }
 */

/*
 
 When the follow button is tapped, we want Makestagram to follow or unfollow the user. However, we won't implement that directly in the FriendSearchTableViewCell. Typically we want to keep more complex functionality outside of our views. Our solution is to define a delegate that will be responsible for performing the follow / unfollow.
 The delegate of each cell will be the FriendSearchViewController. When the follow button is tapped, the FriendTableViewCell will inform the FriendSearchViewController so that it can handle actually making the follow happen.
 We defined the FriendSearchTableViewCellDelegate protocol. Any class that wants to be a delegate of the FriendSearchTableViewCell will have to implement that protocol. Notice that the delegate methods are simply used to inform the delegate of whether a user was selected as followed or not.
 As each FriendSearchTableViewCell is created, the FriendSearchViewController will set itself as the delegate by assigning itself with this delegate property.
 
 */

protocol FriendSearchTableViewCellDelegate: class {
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: FriendSearchTableViewCellDelegate? //we have a property for the delegate
    
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
             Change the state of the follow button based on whether or not
             it is possible to follow a user.
             */
            if let canFollow = canFollow {
                followButton.selected = !canFollow
            }
        }
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true {
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
    }
}