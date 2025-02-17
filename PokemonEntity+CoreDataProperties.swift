//
//  PokemonEntity+CoreDataProperties.swift
//  PokeDex
//
//  Created by Hugo RAGUIN on 2/17/25.
//
//

import Foundation
import CoreData


extension PokemonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonEntity> {
        return NSFetchRequest<PokemonEntity>(entityName: "PokemonEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var stats: NSSet?

}

// MARK: Generated accessors for stats
extension PokemonEntity {

    @objc(addStatsObject:)
    @NSManaged public func addToStats(_ value: PokemonStatEntity)

    @objc(removeStatsObject:)
    @NSManaged public func removeFromStats(_ value: PokemonStatEntity)

    @objc(addStats:)
    @NSManaged public func addToStats(_ values: NSSet)

    @objc(removeStats:)
    @NSManaged public func removeFromStats(_ values: NSSet)

}

extension PokemonEntity : Identifiable {

}
