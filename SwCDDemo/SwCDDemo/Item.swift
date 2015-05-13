//
//  Item.swift
//  SwCD
//
//  Created by xxxAIRINxxx on 2015/05/01.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import Foundation
import CoreData

class Item: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var created: NSDate
    @NSManaged var sorted: NSNumber
    @NSManaged var display: NSNumber
    @NSManaged var name: String

}
