//
//  PokemonTypeEntity+CoreDataProperties.swift
//  PokeDex
//
//  Created by Hugo RAGUIN on 2/17/25.
//
//

import Foundation
import CoreData


extension PokemonTypeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonTypeEntity> {
        return NSFetchRequest<PokemonTypeEntity>(entityName: "PokemonTypeEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var pokemon: PokemonEntity?

}

extension PokemonTypeEntity : Identifiable {

}
