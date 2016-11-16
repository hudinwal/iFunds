//
//  NAV+CoreDataProperties.swift
//  iFunds
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation
import CoreData


extension NAV {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NAV> {
        return NSFetchRequest<NAV>(entityName: "NAV");
    }

    @NSManaged public var nav: Int64
    @NSManaged public var date: NSDate?
    @NSManaged public var forScheme: Scheme?

}
