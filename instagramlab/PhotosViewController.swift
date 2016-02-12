//
//  ViewController.swift
//  instagramlab
//
//  Created by Tim Barnard on 2/4/16.
//  Copyright (c) 2016 Tim Barnard. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //ismoredataloading is for infinite scroll functionality
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var photos :[NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Do any additional setup after loading the view, typically from a nib.
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            // storing returning array/dictionary of media in the property photos
                            self.photos = (responseDictionary["data"] as! [NSDictionary])
                            self.tableView.reloadData()
                    }
                    
                }
        });
        task.resume()
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.instagramlab.photocell", forIndexPath: indexPath) as! PhotoCell
        let photo = photos![indexPath.row]
        let images = photo["images"]
        let sr = images!["standard_resolution"] as! NSDictionary
        if let image_str  = sr["url"] as? String{
            let image_url =  NSURL(string:image_str as! String)
            // let photoURL = NSURL(string: "https://api.instagram.com/v1/media/popular?client_id=e05c462ebd86446ea48a5af73769b602")
            let photoRequest = NSURLRequest(URL: image_url!)
            
            cell.photoView.setImageWithURLRequest(photoRequest, placeholderImage:nil,
                success:{(photoRequest, photoResponse, image) -> Void in
                    
                    cell.photoView.image = image
                    
                    
                    
                }, failure: { (photoRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let photos = photos {
            return photos.count
        }
        return 0//return self.photos.count
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if(!isMoreDataLoading)
        {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading=true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
            
        }
    }
    func loadMoreData()
    {
        //        let session = NSURLSession(
        //            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        //            delegate:nil,
        //            delegateQueue:NSOperationQueue.mainQueue()
        //        )
        //
        //        let task : NSURLSessionDataTask = session.dataTaskWithRequest(photoRequest,
        //            completionHandler: { (data, response, error) in
        //
        //                // Update flag
        //                self.isMoreDataLoading = false
        //
        //                // ... Use the new data to update the data source ...
        //
        //                // Reload the tableView now that there is new data
        //                self.myTableView.reloadData()
        //        });
        //        task.resume()
        //    }
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            // storing returning array/dictionary of media in the property photos
                            self.photos = (responseDictionary["data"] as! [NSDictionary])
                            
                            self.isMoreDataLoading = false
                            
                            // Stop the loading indicator
                            self.loadingMoreView!.stopAnimating()
                            
                            self.tableView.reloadData()
                            
                            
                            // ... Use the new data to update the data source ...
                            
                            // Reload the tableView now that there is new data
                    }
                    
                }
        });
        task.resume()
    }
    class InfiniteScrollActivityView: UIView {
        var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        static let defaultHeight:CGFloat = 60.0
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupActivityIndicator()
        }
        
        override init(frame aRect: CGRect) {
            super.init(frame: aRect)
            setupActivityIndicator()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        }
        
        func setupActivityIndicator() {
            activityIndicatorView.activityIndicatorViewStyle = .Gray
            activityIndicatorView.hidesWhenStopped = true
            self.addSubview(activityIndicatorView)
        }
        
        func stopAnimating() {
            self.activityIndicatorView.stopAnimating()
            self.hidden = true
        }
        
        func startAnimating() {
            self.hidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        
        var indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        */
        
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let photo = photos![indexPath!.row]
        let photodetailsViewController = segue.destinationViewController as! PhotoDetailsViewController
        photodetailsViewController.photo = photo
        
        //tableView.deselectRowAtIndexPath(indexPath!, animated: true)
    }
    
}

