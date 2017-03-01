//
//  FakeURLSession.swift
//  NFYU
//
//  Created by Gianluca Tranchedone on 05/11/2015.
//  Copyright © 2015 Gianluca Tranchedone. All rights reserved.
//

import Foundation

class FakeURLSessionDataTask: URLSessionDataTask {
    
    fileprivate(set) var started = false
    let completionHandler: ((Data?, URLResponse?, NSError?) -> Void)?
    
    let stubOriginalRequest: URLRequest
    override var originalRequest: URLRequest {
        return stubOriginalRequest
    }
    
    init(stubRequest: URLRequest, completionHandler: ((Data?, URLResponse?, NSError?) -> Void)? = nil) {
        stubOriginalRequest = stubRequest
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        started = true
    }
    
}

class FakeURLSession: URLSession {
    
    private(set) var lastCreatedDataTask: URLSessionDataTask?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        lastCreatedDataTask = FakeURLSessionDataTask(stubRequest: request, completionHandler: completionHandler)
        return lastCreatedDataTask!
    }
    
}
