//
//  Game+CoreDataClass.swift
//  shelf-proj
//
//  Created by Bemo on 9/17/22.
//
//

import Foundation
import CoreData


public class Game: NSManagedObject {
    // Note: This initializer will be used for CoreData's internal operations
    // You generally don't need to call this directly
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // This is the designated initializer you can use
    public init(name: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Game", in: context)
        super.init(entity: entity!, insertInto: context)
        
        self.title = name
    }
}
