//
//  Game+CoreDataProperties.swift
//  shelf-proj
//
//  Created by Bemo on 9/17/22.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var title: String?
    @NSManaged public var system: String?
    @NSManaged public var desc: String?
    @NSManaged public var cover_art: String?

}

extension Game : Identifiable {

}
