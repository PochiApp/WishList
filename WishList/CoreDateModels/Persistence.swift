//
//  Persistence.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/13.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // MARK: 下2行はEntityの設定によって違う
        let newFolderModel = FolderModel(context: viewContext)
        newFolderModel.title = ""
        newFolderModel.startDate = Date()
        newFolderModel.finishDate = Date()
        newFolderModel.backColor = ""
        newFolderModel.writeDate = Date()
        newFolderModel.notDaySetting = false
        newFolderModel.lockIsActive = false
        newFolderModel.folderPassword = ""
        newFolderModel.lists = []
        newFolderModel.achievedLists = []
        
        let newListModel = ListModel(context: viewContext)
        newListModel.text = ""
        newListModel.category = ""
        newListModel.listNumber = Int16(0)
        newListModel.achievement = false
        newListModel.folderDate = Date()
        newListModel.image1 = Data.init()
        newListModel.image2 = Data.init()
        newListModel.miniMemo = ""
        
        let newCategoryEntity = CategoryEntity(context: viewContext)
        newCategoryEntity.categoryName = ""
        newCategoryEntity.categoryAddDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // MARK: 下1行はEntityの設定によって違う
        //プロジェクト名「WishList」に変更する前がBucketListだったので、このnameがついている。下手に変更すると面倒くさそうなのでそのまま。
        container = NSPersistentContainer(name: "BucketList")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
