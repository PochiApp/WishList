//
//  ListModel+CoreDataProperties.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/13.
//
//

import Foundation
import CoreData


extension ListModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListModel> {
        return NSFetchRequest<ListModel>(entityName: "ListModel")
    }

    @NSManaged public var text: String?
    @NSManaged public var category: String?
    @NSManaged public var listNumber: Int16
    @NSManaged public var achievement: Bool
    @NSManaged public var folderDate: Date?
    @NSManaged public var image1: Data?
    @NSManaged public var image2: Data?
    

}

extension ListModel : Identifiable {

}
