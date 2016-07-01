//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Veronica Tan on 1/7/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

class PostSectionHeaderView: UITableViewCell {
    
    
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var post: Post? {
        didSet {
            if let post = post {
                usernameLabel.text = post.user?.username
                // 1
                postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
                
/* We are reading the createdAt date from the post. This is a property that Parse sets automatically on all PFObjects. Then we use an extension provided by the DateTools library: shortTimeAgoSinceDate(_:). This method takes a comparison date. By calling NSDate() we create a date object with the current time. If the post has been created 4 hours ago, this line of code will generate the string "4h". Since createdAt? is an optional, we use the ?? operator to fall back to an empty string, just in case the createdAt date is nil.
 */
            }
        }
    }
    
}
