//
//  Persistence.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/13.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    let iCloudContainer: NSPersistentCloudKitContainer?
    private var observer: NSObjectProtocol?

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
        newFolderModel.folderIndex = Int16(0)

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
    
    init(inMemory: Bool = false) {
        if UserDefaults.standard.bool(forKey: "isICloudEnabled") {
            // iCloud連携が有効の場合、iCloudコンテナを使用
            iCloudContainer = NSPersistentCloudKitContainer(name: "BucketList")
            if let description = iCloudContainer!.persistentStoreDescriptions.first {
                description.cloudKitContainerOptions =
                    NSPersistentCloudKitContainerOptions(
                        containerIdentifier:
                            "iCloud.com.gmail.dp.app.pochi.BucketList"
                    )

                // ローカルデータの保存場所を設定
                description.url = NSPersistentContainer.defaultDirectoryURL()
                    .appendingPathComponent("BucketList_Cloud.sqlite")

                // iCloud同期用の設定
                description.setOption(
                    true as NSNumber,
                    forKey: NSPersistentHistoryTrackingKey
                )
                description.setOption(
                    true as NSNumber,
                    forKey:
                        NSPersistentStoreRemoteChangeNotificationPostOptionKey
                )
            }
            iCloudContainer!.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })

            // 親子コンテキストの自動マージを有効にする
            iCloudContainer!.viewContext.automaticallyMergesChangesFromParent = true
            // データが重複しないよう外部変更はメモリ内を置き換える
            iCloudContainer!.viewContext.mergePolicy =
                NSMergeByPropertyObjectTrumpMergePolicy
            container = iCloudContainer!
            
            //開発時のみ、スキーマの作成664
//            let options = NSPersistentCloudKitContainerSchemaInitializationOptions()
//            try? iCloudContainer!.initializeCloudKitSchema(options: options)
        } else {
            // ローカルモード
            //プロジェクト名「WishList」に変更する前がBucketListだったので、このnameがついている。下手に変更すると面倒くさそうなのでそのまま。
            container = NSPersistentContainer(name: "BucketList")

            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })

            // 親子コンテキストの自動マージを有効にする
            container.viewContext.automaticallyMergesChangesFromParent = true
            // データが重複しないよう外部変更はメモリ内を置き換える
            container.viewContext.mergePolicy =
                NSMergeByPropertyObjectTrumpMergePolicy
            
            iCloudContainer = nil
        }
    }
}
