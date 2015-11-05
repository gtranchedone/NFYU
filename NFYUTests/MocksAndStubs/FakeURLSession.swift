//
//  FakeURLSession.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class FakeURLSessionDataTask: NSURLSessionDataTask {
    
    private(set) var started = false
    let completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?
    
    let stubOriginalRequest: NSURLRequest
    override var originalRequest: NSURLRequest {
        get { return stubOriginalRequest }
    }
    
    init(stubRequest: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)? = nil) {
        stubOriginalRequest = stubRequest
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        started = true
    }
    
}

class FakeURLSession: NSURLSession {
    
    private(set) var lastCreatedDataTask: NSURLSessionDataTask?
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        lastCreatedDataTask = FakeURLSessionDataTask(stubRequest: request, completionHandler: completionHandler)
        return lastCreatedDataTask!
    }
    
}
