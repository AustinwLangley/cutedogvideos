//
//  TableViewController.swift
//  Cute Dog Videos
//
//  Created by AL on 11/6/15.
//  Copyright © 2015 AL. All rights reserved.
//

import UIKit
import StoreKit

class TableViewController: UITableViewController, IAPManagerDelegate {
    
    var programs = [Program]()
    var trimmedPrograms = [Program]()
    
    @IBAction func restorePurchases(){
        IAPManager.sharedInstance.restorePurchases()
    }
    
    func managerDidRestorePurchases() {
        let alertController = UIAlertController(title: "In-App Purchase", message: "Any missing purchases have been restored", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func subscribe(sender: AnyObject) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("com.CuteDogVideos.apc"){
            print("active")
        } else {
            let alertController = UIAlertController(title: "Rewatch Past Dog Videos", message: "For a one time payment of $4.99, you will be able to rewatch previous videos.", preferredStyle: .Alert)
            let purchaseAction = UIAlertAction(title: "Purchase", style: .Default) { (action) -> Void in
                print(IAPManager.sharedInstance.products.objectAtIndex(0))
                IAPManager.sharedInstance.createPaymentRequestForProduct(IAPManager.sharedInstance.products.objectAtIndex(0) as! SKProduct)
            }
            
            let noThanksAction = UIAlertAction(title: "No Thanks", style: .Default, handler: nil)
            
            alertController.addAction(purchaseAction)
            alertController.addAction(noThanksAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    enum ThumbnailQuailty : String {
        case Zero = "0.jpg"
        case One = "1.jpg"
        case Two = "2.jpg"
        case Three = "3.jpg"
        
        case Default = "default.jpg"
        case Medium = "mqdefault.jpg"
        case High = "hqdefault.jpg"
        case Standard = "sddefault.jpg"
        case Max = "maxresdefault.jpg"
        
        /// All values sorted by image size (1,2,3 are the same size)
        static let allValues = [Default, One, Two, Three,  Medium, High, Zero, Standard, High]
    }
    
    func thumbnailURLString(videoID:String, quailty: ThumbnailQuailty = .Default) -> String {
        return "https://img.youtube.com/vi/\(videoID)/\(quailty.rawValue)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPManager.sharedInstance.delegate = self
        
        self.title = "Cute Dog Videos"
        
        retrivePrograms()
        
//        if Reachability.isConnectedToNetwork() == true {
//            retrivePrograms()
//        } else {
//            print("Internet connection FAILED")
//            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet and restart app.", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableData", name: "applicationWillEnterForeground", object: nil)
        
    }
    
    func reloadTableData() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let now = NSDate()
        var returnValue = 0
        
        let launchDate = NSUserDefaults.standardUserDefaults().objectForKey("launchDate") as! NSDate!
//        print("\(launchDate)")
        
        var fireDatesArray = [NSDate]()
        
        //start creating firedates after all programs have loaded
        if programs.count != 0 {
            
            for day in 0..<(programs.count / 3) {
                
                let fireDayComponents = NSDateComponents()
                fireDayComponents.setValue(day, forComponent: NSCalendarUnit.Day)
                
                let notificationDay = NSCalendar.currentCalendar().dateByAddingComponents(fireDayComponents, toDate: launchDate, options: NSCalendarOptions(rawValue: 0))
                let fireTimeMorning = NSCalendar.currentCalendar().dateBySettingHour(6, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
                let fireTimeNoon = NSCalendar.currentCalendar().dateBySettingHour(12, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
                let fireTimeEvening = NSCalendar.currentCalendar().dateBySettingHour(18, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .ShortStyle
                formatter.timeStyle = .LongStyle
                
                
                fireDatesArray.append(fireTimeMorning!)
//                var string = formatter.stringFromDate(fireTimeMorning!)
//                print("FireDates Array" + string)
                fireDatesArray.append(fireTimeNoon!)
//                string = formatter.stringFromDate(fireTimeNoon!)
//                print("FireDates Array" + string)
                fireDatesArray.append(fireTimeEvening!)
//                string = formatter.stringFromDate(fireTimeEvening!)
//                print("FireDates Array" + string)
                
                
                
            }
            
            var fireDateComparisonArray = [NSComparisonResult]()
            
            for count in 0..<programs.count {
                let dateComparisionResult:NSComparisonResult = now.compare(fireDatesArray[count])
                fireDateComparisonArray.append(dateComparisionResult)
            }
            
            for count in 0..<programs.count {
                if fireDateComparisonArray[count] == NSComparisonResult.OrderedDescending
                {
                    trimProgramsAndReverse(count + 1)
                    returnValue = count + 1
//                    print("The in loop return value is \(returnValue)")
                }
            }
        }
//        print("The main return value is \(returnValue)")
        return returnValue
    }

    func trimProgramsAndReverse(rangeStart: Int) {
//        print("total number of programs is \(programs.count)")
//        print("The rangeStart is \(rangeStart)")
        trimmedPrograms = programs
        if rangeStart < (programs.count-1) {
            trimmedPrograms.removeRange(rangeStart...(programs.count-1))
        }
        trimmedPrograms = trimmedPrograms.reverse()
//        print("total number of programs after trim \(trimmedPrograms.count)")
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
//      print(indexPath.row)
        let currentProgram = trimmedPrograms[indexPath.row]

        cell.textLabel!.text = "Day \(currentProgram.day): \(currentProgram.videoTitle)"
//      cell.textLabel!.text = currentProgram.quote
        cell.detailTextLabel!.text = "Video length: \(currentProgram.videoTime)"
        
            if indexPath.row != 0 {
                cell.backgroundColor = UIColor.lightGrayColor()
            }
            if indexPath.row == 0 {
                cell.backgroundColor = UIColor.clearColor()
            }
    
        let videoURL = NSURL(string: currentProgram.video)
        let videoID = videoURL?.lastPathComponent
        let youtubeImageURL = thumbnailURLString(videoID!)
        
        if let imageData = NSData(contentsOfURL: NSURL(string: youtubeImageURL)!) {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            let imageData = UIImage(named: "cute_dog_videos_logo")
            cell.imageView?.image = imageData
        }
        
        return cell
    }
  
    func retrivePrograms() {
        let programService = ProgramService()
        programService.getProgram() {
            
            (let course) in
            dispatch_async(dispatch_get_main_queue()) {
                self.programs = course!.allPrograms
//                print(self.programs)
                self.reloadTableData()
                self.generateLocalNotifications()
                
                if self.programs.count < 270 || self.programs.count > 1001 {
                    let alert = UIAlertView(title: "The app couldn't retrive all the videos", message: "Make sure your device is connected to the internet and restart the app.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }

    func generateLocalNotifications() {
        let launchDate = NSUserDefaults.standardUserDefaults().objectForKey("launchDate") as! NSDate!
        var fireDays = [NotificationDate]()
        let currentDate = NSDate()
        
        //created fire days for the future
        for day in 0..<(programs.count / 3) {
            
            let fireDayComponents = NSDateComponents()
            fireDayComponents.setValue(day, forComponent: NSCalendarUnit.Day)
            
            let notificationDay = NSCalendar.currentCalendar().dateByAddingComponents(fireDayComponents, toDate: launchDate, options: NSCalendarOptions(rawValue: 0))
            
            let fireTimeMorning = NSCalendar.currentCalendar().dateBySettingHour(6, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
            let fireTimeNoon = NSCalendar.currentCalendar().dateBySettingHour(12, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
            let fireTimeEvening = NSCalendar.currentCalendar().dateBySettingHour(18, minute: 0, second: 0, ofDate: notificationDay!, options: NSCalendarOptions(rawValue: 0))
            
            let notificationDate = NotificationDate(day: notificationDay!, fireTimeMorning: fireTimeMorning!, fireTimeNoon:  fireTimeNoon!, fireTimeEvening: fireTimeEvening!)
            
            fireDays.append(notificationDate)
            
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .LongStyle
//        let launchString = formatter.stringFromDate(launchDate!)
//        let currentString = formatter.stringFromDate(currentDate)
        
//        print("***********************************")
//        print("The Launch date is:" + launchString)
//        print("The current date is:" + currentString)
//        print("Notification List:")
        
        var badgeCount = 1
        for count in 0..<(programs.count / 3) {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .LongStyle
            
            let morningNotification = UILocalNotification()
            morningNotification.alertBody = "You have a new Cute Dog Video to Watch!"
            morningNotification.fireDate = fireDays[count].fireTimeMorning
            morningNotification.soundName = UILocalNotificationDefaultSoundName
            morningNotification.applicationIconBadgeNumber = badgeCount
//            var string = formatter.stringFromDate(morningNotification.fireDate!)
//            print(string + " The badge count is \(badgeCount)")
            badgeCount += 1
            //Schedule morning notification
            
            let morningDateComparisionResult:NSComparisonResult = currentDate.compare(morningNotification.fireDate!)
            if morningDateComparisionResult == NSComparisonResult.OrderedAscending {
                UIApplication.sharedApplication().scheduleLocalNotification(morningNotification)
//                print("Morning Notification was set")
            }
          
            let noonNotification = UILocalNotification()
            noonNotification.alertBody = "You have a new Cute Dog Video to Watch!"
            noonNotification.fireDate = fireDays[count].fireTimeNoon
            noonNotification.soundName = UILocalNotificationDefaultSoundName
            noonNotification.applicationIconBadgeNumber = badgeCount
//            string = formatter.stringFromDate(noonNotification.fireDate!)
//            print(string + " The badge count is \(badgeCount)")
            badgeCount += 1
            //Schedule noon notification
            let noonDateComparisionResult:NSComparisonResult = currentDate.compare(noonNotification.fireDate!)
            if noonDateComparisionResult == NSComparisonResult.OrderedAscending {
                UIApplication.sharedApplication().scheduleLocalNotification(noonNotification)
//                print("Noon Notification was set")
            }
            
            let eveningNotification = UILocalNotification()
            eveningNotification.alertBody = "You have a new Cute Dog Video to Watch!"
            eveningNotification.fireDate = fireDays[count].fireTimeEvening
            eveningNotification.soundName = UILocalNotificationDefaultSoundName
            eveningNotification.applicationIconBadgeNumber = badgeCount
//            string = formatter.stringFromDate(eveningNotification.fireDate!)
//            print(string + " The badge count is \(badgeCount)")
            badgeCount += 1
            //Schedule evening notification
            let eveningDateComparisionResult:NSComparisonResult = currentDate.compare(eveningNotification.fireDate!)
            if eveningDateComparisionResult == NSComparisonResult.OrderedAscending {
                UIApplication.sharedApplication().scheduleLocalNotification(eveningNotification)
//                print("Evening Notification was set")
            }
        }
//        print("*******************************")
//        print("The list of scheduled notificaitons")
//        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
//        for count in 0..<scheduledNotifications!.count {
////            print("\(count + 1) \(scheduledNotifications![count])")
//        }
     
    }
    
    // MARK: - Navigation

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        if NSUserDefaults.standardUserDefaults().boolForKey("com.CuteDogs.product"){
            performSegueWithIdentifier("detailViewController", sender: self)
        } else {
            if indexPath.row == 0 {
              performSegueWithIdentifier("detailViewController", sender: self)
            } else {
                let alertController = UIAlertController(title: "Action Required", message: "You only have access to the latest video. You must unlock below to access any past videos.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "detailViewController") {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let secondScene = segue.destinationViewController as! ViewController
                let selectedProgram = trimmedPrograms[indexPath.row]
                secondScene.currentProgram = selectedProgram
            }
        }
        
    }
}
