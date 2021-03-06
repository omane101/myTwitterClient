//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Malik Browne on 2/10/16.
//  Copyright © 2016 Malik Browne. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var tweets: [Tweet]!
    var selectedTweet: Tweet!
    var isMoreDataLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        loadData()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        let twitterLogo : UIImage = UIImage(named: "twitter")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        imageView.contentMode = .Center
        imageView.image = twitterLogo
        self.navigationItem.titleView = imageView
        
    }
    
    override func viewDidAppear(animated: Bool) {
        loadData()
    }
    
    func loadData() {
        TwitterClient.sharedInstance.homeTimeLineWithParams(nil, completion: { (tweets, error) -> () in
            
            self.tweets = tweets
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeLineWithParams(nil, completion: { (tweets, error) -> () in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // ... Use the new data to update the data source ...
            self.tweets = tweets
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        })
    }
    
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedTweet = tweets![indexPath.row]
        
        return indexPath
    }
    
    
    @IBAction func onProfileImageTap(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TweetCell
        let indexPath = tableView.indexPathForCell(cell)
        selectedTweet = tweets![indexPath!.row]
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationViewController = segue.destinationViewController
        
        if let destinationViewController = destinationViewController as? TweetDetailsViewController {
            destinationViewController.selectedTweet = selectedTweet
            destinationViewController.user = selectedTweet.user
            
        }
        
        else if let destinationViewController = destinationViewController as? ProfileViewController {
            destinationViewController.user = selectedTweet.user!
        }
        
        else if let destinationViewController = destinationViewController as? CreateTweetViewController {
            destinationViewController.user = User.currentUser
        }
        
    }


}
