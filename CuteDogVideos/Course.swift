//
//  Course.swift
//  Cute Dog Videos
//
//  Created by AL on 11/6/15.
//  Copyright © 2015 AL. All rights reserved.
//

import Foundation

struct Course {
    var allPrograms: [Program] = []
    var programDay = 1
    
    init(programArray: [[String: AnyObject]]?) {
        if let courseArray = programArray {
            
            for item in courseArray {
                var quote = item["wealth_quote"] as! String
                var video = item["wealth_video"] as! String
                var videoTime = item["wealth_video_time"] as! String
                var day = programDay
                var videoTitle = "Morning Cute Dog Video"
                let currentProgramOne = Program(quote: quote, video: video, videoTime: videoTime, day: day, videoTitle: videoTitle)
                quote = item["health_quote"] as! String
                video = item["health_video"] as! String
                videoTime = item["health_video_time"] as! String
                day = programDay
                videoTitle = "Lunch Time Cute Dog Video"
                let currentProgramTwo = Program(quote: quote, video: video, videoTime: videoTime, day: day, videoTitle: videoTitle)
                quote = item["love_quote"] as! String
                video = item["love_video"] as! String
                videoTime = item["love_video_time"] as! String
                day = programDay
                videoTitle = "Evening Cute Dog Video"
                let currentProgramThree = Program(quote: quote, video: video, videoTime: videoTime, day: day, videoTitle: videoTitle)
                
                allPrograms.append(currentProgramOne)
                allPrograms.append(currentProgramTwo)
                allPrograms.append(currentProgramThree)
                programDay += 1
            }
        }
    }
}