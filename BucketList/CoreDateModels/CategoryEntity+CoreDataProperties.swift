//
//  CategoryEntity+CoreDataProperties.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/04.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var categoryAddDate: Date?
    @NSManaged public var categoryName: String?

}

extension CategoryEntity : Identifiable {

}
