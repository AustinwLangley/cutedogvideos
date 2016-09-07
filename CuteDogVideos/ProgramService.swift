//
//  ProgramService.swift
//  Cute Dog Videos
//
//  Created by AL on 11/6/15.
//  Copyright © 2015 AL. All rights reserved.
//

import Foundation

struct ProgramService {
    let programURL: NSURL?
    
    init() {
        programURL = NSURL(string: "https://api/program_list.json")
    }
    
    func getProgram(completion: (Course? -> Void)) {
        
        let networkOperation = NetworkOperation(url: programURL!)
        
        networkOperation.downloadJSONFromURL {
            (let JSONArray) in
            let course = Course(programArray: JSONArray)
            completion(course)
        }
        
    }
    
}
