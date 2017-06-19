//
//  ReportDownloader.swift
//  iFunds
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation

typealias downloadCallBack = ((Bool)->())

class ReportDownloader {
    let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60*5.0
        configuration.httpMaximumConnectionsPerHost = 1
        session = URLSession(configuration: configuration)
    }
    
    func downloadReportToDisk(url:URL,fileURL:URL,callBack:@escaping downloadCallBack) {
        let dataTask = session.dataTask(with: url, completionHandler: {(data:Data?, response:URLResponse?, error:Error?) -> Void in
            guard (error == nil) else {
                callBack(false)
                return
            }
            if let data = data  {
                
                do {
                    try data.write(to: fileURL)
                    callBack(true)
                }
                catch {
                    print("Error : File writing failed for url(\(url.absoluteString))")
                    callBack(false)
                    return
                }
            }
        })
        dataTask.resume()
    }
}
