//
//  FolderModel+CoreDataProperties.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/18.
//
//

import Foundation
import CoreData


extension FolderModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FolderModel> {
        return NSFetchRequest<FolderModel>(entityName: "FolderModel")
    }

    @NSManaged public var title: String?
    @NSManaged public var startDateString: String?
    @NSManaged public var finishDateString: String?
    @NSManaged public var backColor: Int16

}

extension FolderModel : Identifiable {

}
