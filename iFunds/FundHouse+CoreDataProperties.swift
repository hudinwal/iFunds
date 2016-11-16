//
//  FundHouse+CoreDataProperties.swift
//  iFunds
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import Foundation
import CoreData


extension FundHouse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FundHouse> {
        return NSFetchRequest<FundHouse>(entityName: "FundHouse");
    }

    @NSManaged public var name: String?
    @NSManaged public var managesSchemes: NSSet?

}

// MARK: Generated accessors for managesSchemes
extension FundHouse {

    @objc(addManagesSchemesObject:)
    @NSManaged public func addToManagesSchemes(_ value: Scheme)

    @objc(removeManagesSchemesObject:)
    @NSManaged public func removeFromManagesSchemes(_ value: Scheme)

    @objc(addManagesSchemes:)
    @NSManaged public func addToManagesSchemes(_ values: NSSet)

    @objc(removeManagesSchemes:)
    @NSManaged public func removeFromManagesSchemes(_ values: NSSet)

}
