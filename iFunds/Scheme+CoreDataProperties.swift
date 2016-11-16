//
//  Scheme+CoreDataProperties.swift
//  iFunds
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation
import CoreData


extension Scheme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scheme> {
        return NSFetchRequest<Scheme>(entityName: "Scheme");
    }

    @NSManaged public var schemeCode: Int32
    @NSManaged public var schemeName: String?
    @NSManaged public var schemeType: String?
    @NSManaged public var belongsToFundHouse: FundHouse?
    @NSManaged public var navs: NSSet?

}

// MARK: Generated accessors for navs
extension Scheme {

    @objc(addNavsObject:)
    @NSManaged public func addToNavs(_ value: NAV)

    @objc(removeNavsObject:)
    @NSManaged public func removeFromNavs(_ value: NAV)

    @objc(addNavs:)
    @NSManaged public func addToNavs(_ values: NSSet)

    @objc(removeNavs:)
    @NSManaged public func removeFromNavs(_ values: NSSet)

}
