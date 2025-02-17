//
//  PokemonStatEntity+CoreDataProperties.swift
//  PokeDex
//
//  Created by Hugo RAGUIN on 2/17/25.
//
//

import Foundation
import CoreData


extension PokemonStatEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonStatEntity> {
        return NSFetchRequest<PokemonStatEntity>(entityName: "PokemonStatEntity")
    }

    @NSManaged public var baseStat: Int64
    @NSManaged public var name: String?
    @NSManaged public var pokemon: PokemonEntity?

}

extension PokemonStatEntity : Identifiable {

}
