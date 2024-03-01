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
    @NSManaged public var startDate: Date?
    @NSManaged public var finishDate: Date?
    @NSManaged public var backColor: Int16
    @NSManaged public var writeDate: Date?
    @NSManaged public var notDaySetting: Bool
    @NSManaged public var lists: NSArray?
    @NSManaged public var achievedLists: NSArray?
}

extension FolderModel : Identifiable {

}

extension FolderModel {
    public var unwrappedTitle: String { title ?? "" }
    public var unwrappedStartDate: Date { startDate ?? Date() }
    public var unwrappedFinishDate: Date { finishDate ?? Date() }
    public var unwrappedWriteDate: Date { writeDate ?? Date() }
    public var unwrappedLists: [ListModel]  { lists as? [ListModel] ?? [] }
    public var unwrappedAchievedLists: [ListModel]  { achievedLists as? [ListModel] ?? [] }
    
}
