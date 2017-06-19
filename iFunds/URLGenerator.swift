//
//  URLGenerator.swift
//  iFunds
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation

let fundHouseIDs = [
 39:"ABN  AMRO Mutual Fund",
 50:"AEGON Mutual Fund",
 1:"Alliance Capital Mutual Fund",
 53:"Axis Mutual Fund",
 4:"Baroda Pioneer Mutual Fund",
 36:"Benchmark Mutual Fund",
 3:"Birla Sun Life Mutual Fund",
 59:"BNP Paribas Mutual Fund",
 46:"BOI AXA Mutual Fund",
 32:"Canara Robeco Mutual Fund",
 60:"Daiwa Mutual Fund",
 31:"DBS Chola Mutual Fund",
 38:"Deutsche Mutual Fund",
 58:"DHFL Pramerica Mutual Fund",
 6:"DSP BlackRock Mutual Fund",
 47:"Edelweiss Mutual Fund",
 13:"Escorts Mutual Fund",
 40:"Fidelity Mutual Fund",
 51:"Fortis Mutual Fund",
 27:"Franklin Templeton Mutual Fund",
 8:"GIC Mutual Fund",
 49:"Goldman Sachs Mutual Fund",
 9:"HDFC Mutual Fund",
 37:"HSBC Mutual Fund",
 20:"ICICI Prudential Mutual Fund",
 57:"IDBI Mutual Fund",
 48:"IDFC Mutual Fund",
 68:"IIFCL Mutual Fund (IDF)",
 62:"IIFL Mutual Fund",
 11:"IL&amp;F S Mutual Fund",
 65:"IL&amp;FS Mutual Fund (IDF)",
 63:"Indiabulls Mutual Fund",
 14:"ING Mutual Fund",
 42:"Invesco Mutual Fund",
 16:"JM Financial Mutual Fund",
 43:"JPMorgan Mutual Fund",
 17:"Kotak Mahindra Mutual Fund",
 56:"L&amp;T Mutual Fund",
 18:"LIC Mutual Fund",
 69:"Mahindra Mutual Fund",
 45:"Mirae Asset Mutual Fund",
 19:"Morgan Stanley Mutual Fund",
 55:"Motilal Oswal Mutual Fund",
 54:"Peerless Mutual Fund",
 44:"PineBridge Mutual Fund",
 34:"PNB Mutual Fund",
 64:"PPFAS Mutual Fund",
 10:"PRINCIPAL Mutual Fund",
 41:"Quantum Mutual Fund",
 21:"Reliance Mutual Fund",
 35:"Sahara Mutual Fund",
 22:"SBI Mutual Fund",
 52:"Shinsei Mutual Fund",
 67:"Shriram Mutual Fund",
 66:"SREI Mutual Fund (IDF)",
 2:"Standard Chartered Mutual Fund",
 24:"SUN F&amp;C Mutual Fund",
 33:"Sundaram Mutual Fund",
 25:"Tata Mutual Fund",
 26:"Taurus Mutual Fund",
 61:"Union Mutual Fund",
 28:"UTI Mutual Fund",
 29:"Zurich India Mutual Fund"
]

let typeIDs = [
    1:"Open Ended Schemes",
    2:"Close Ended Schemes",
    3:"Interval Fund"
]

let fromDataKey = "frmdt"
let toDateKey = "todt"
let fundHouseKey = "mf"
let typeKey = "tp"

extension URL {
    
    private static func dateString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        return dateFormatter.string(from: date)
    }
    
    static func urlToFindNAVs(fromDate:Date,toDate:Date?=nil, fundHouseName:String? = nil,fundType:String? = nil) -> URL?
    {
        var queryItems = [URLQueryItem]()
        
        // From Date Query
        let fromdateString = self.dateString(date: fromDate)
        queryItems.append(URLQueryItem(name: fromDataKey, value:fromdateString))
        
        // To Date Query
        if let toDate = toDate {
            let toDateString = self.dateString(date: toDate)
            queryItems.append(URLQueryItem(name: toDateKey, value:toDateString))
        }
        
        // Fund House Query
        if let fundHouseName = fundHouseName {
            for key in fundHouseIDs {
                if key.value.contains(fundHouseName) {
                    queryItems.append(URLQueryItem(name: fundHouseKey, value: "\(key.key)"))
                    break
                }
            }
        }
        // Fund Type Query
        if let fundType = fundType {
            for key in typeIDs {
                if key.value.contains(fundType) {
                    queryItems.append(URLQueryItem(name: typeKey, value: "\(key.key)"))
                    break
                }
            }
        }
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "portal.amfiindia.com"
        components.path = "/DownloadNAVHistoryReport_Po.aspx"
        components.queryItems = queryItems
        return components.url
    }
    
    static func fileURL(fileName:String) -> URL? {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        url = url?.appendingPathComponent(fileName)
        return url
    }
}
