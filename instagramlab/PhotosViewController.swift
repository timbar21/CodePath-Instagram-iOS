//
//  ViewController.swift
//  instagramlab
//
//  Created by Tim Barnard on 2/4/16.
//  Copyright (c) 2016 Tim Barnard. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var photos :[NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let photos = photos {
                   return photos.count
        }
        return 0//return self.photos.count
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

