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
    @NSManaged public var miniMemo: String?
    

}

extension ListModel : Identifiable {

}

extension ListModel {
    public var unwrappedText: String { text ?? "" }
    public var unwrappedCategory: String { category ?? "" }
    public var unwrappedFolderDate: Date { folderDate ?? Date() }
    public var unwrappedImage1: Data { image1 ?? Data.init() }
    public var unwrappedImage2: Data { image2 ?? Data.init() }
    public var unwrappedMiniMemo: String { miniMemo ?? "" }
    
}
