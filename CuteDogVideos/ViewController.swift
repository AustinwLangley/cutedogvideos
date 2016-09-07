//
//  ViewController.swift
//  Cute Dog Videos
//
//  Created by AL on 11/6/15.
//  Copyright © 2015 AL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var currentProgram: Program?
    
    @IBOutlet weak var videoView: UIWebView!
    
    @IBOutlet weak var quoteLabel: UILabel!
    
    @IBAction func Share(sender: AnyObject) {
        let firstActivityItem = currentProgram!.quote
//        let secondActivityItem = currentProgram!.video
        
        let activityViewController = UIActivityViewController(activityItems: ["Cute Dog Videos", firstActivityItem, "Itunes Cute Dog Video Link"], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteLabel.text = currentProgram!.quote
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        configureVideo()
    }

    func configureVideo() {
        
        
        let videoURL = NSURL(string: currentProgram!.video)
        let videoID = videoURL?.lastPathComponent
        
        let videoString = "<iframe width=\"\(Int(videoView.frame.width - 16))\" height=\"\(Int(videoView.frame.height - 15))\" src=\"https://www.youtube.com/embed/\(videoID!)?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>"
        
        self.videoView.allowsInlineMediaPlayback = true
        self.videoView.loadHTMLString(videoString, baseURL: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

