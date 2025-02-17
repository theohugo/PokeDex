//
//  FavoritePokemonEntity+CoreDataProperties.swift
//  PokeDex
//
//  Created by Hugo RAGUIN on 2/17/25.
//
//

import Foundation
import CoreData


extension FavoritePokemonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePokemonEntity> {
        return NSFetchRequest<FavoritePokemonEntity>(entityName: "FavoritePokemonEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var imageURL: String?

}

extension FavoritePokemonEntity : Identifiable {

}
