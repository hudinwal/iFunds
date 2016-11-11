//
//  Scheme+CoreDataClass.swift
//  iFunds
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


public class Scheme: NSManagedObject {
    func fill(json:Any) {
        //TODO Filling of Scheme with JSON
    }
    func fill(charSeparatedString:String, separatorString:String) {
        //TODO Filling of Scheme with string with separator
        let components = charSeparatedString.components(separatedBy: separatorString)
        self.schemeCode = Int32(components[0]) ?? 0
        self.schemeName = components[3]
    }
}
