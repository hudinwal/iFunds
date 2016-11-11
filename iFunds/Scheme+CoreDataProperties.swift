//
//  Scheme+CoreDataProperties.swift
//  iFunds
//
//  Created by Dinesh Kumar on 15/10/16.
//  Copyright © 2016 Organization. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Scheme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scheme> {
        return NSFetchRequest<Scheme>(entityName: "Scheme");
    }

    @NSManaged public var schemeCode: Int32
    @NSManaged public var schemeName: String?
    @NSManaged public var schemeType: Int32

}
