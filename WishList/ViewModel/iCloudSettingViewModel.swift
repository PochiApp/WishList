//
//  iCloudSettingViewModel.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/10/11.
//

import CloudKit
import CoreData
import SwiftUI

@MainActor
class iCloudSettingViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var showAccountAlert = false
    @Published var pendingToggleValue = false
    @Published var cloudHasData: Bool = false
    @Published var syncCompleted: Bool = false
    @Published var syncFailed: Bool = false

    // MARK: - iCloudアカウントにサインインしているかチェック
    func checkiCloudAccountStatus() async -> Bool {
        let container = CKContainer.default()
        do {
            let status = try await container.accountStatus()
            print("iCloudアカウント連携確認 status: \(status)")
            return status == .available
        } catch {
            print("iCloudアカウント確認エラー error: \(error)")
            return false
        }
    }

    // MARK: - CloudKitにデータが存在するかチェック
    func checkiCloudHasData() async throws -> Bool {
        let container = CKContainer(
            identifier: "iCloud.com.gmail.dp.app.pochi.BucketList"
        )
        let database = container.privateCloudDatabase
        let now = Date()

        let query = CKQuery(
            recordType: "CD_FolderModel",
            predicate: NSPredicate(format: "CD_writeDate != %@", now as CVarArg)
        )
        let (matchedRecords, _) = try await database.records(
            matching: query,
            resultsLimit: 1
        )
        return !matchedRecords.isEmpty
    }

    // MARK: - NSPersistentContainerを非同期でロード
    func loadStores(container: NSPersistentContainer) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - iCloudコンテナ作成
    func createiCloudContainer(_ localDbPathComponent: String) async throws
        -> NSPersistentCloudKitContainer
    {
        print("iCloudコンテナ作成開始")
        // iCloud用のデータキャッシュは、同期トラブル回避のため既存のローカルDBとは別名
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent(localDbPathComponent)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        // iCloudコンテナIDの設定
        storeDescription.cloudKitContainerOptions =
            NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.gmail.dp.app.pochi.BucketList"
            )

        // iCloud同期用の設定
        storeDescription.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        storeDescription.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        // 同期用のコンテナを生成 name:モデル名
        let container = NSPersistentCloudKitContainer(name: "BucketList")
        container.persistentStoreDescriptions = [storeDescription]

        // 親子コンテキストの自動マージを有効にする
        container.viewContext.automaticallyMergesChangesFromParent = true
        // データが重複しないよう外部変更はメモリ内を置き換える
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }

    // MARK: - ローカルコンテナ作成
    func createLocalContainer(_ localDbPathComponent: String) async throws
        -> NSPersistentContainer
    {
        print("ローカルコンテナ作成開始")
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent(localDbPathComponent)
        let localDesc = NSPersistentStoreDescription(url: localStoreURL)
        let localContainer = NSPersistentContainer(name: "BucketList")
        localContainer.persistentStoreDescriptions = [localDesc]
        try await loadStores(container: localContainer)

        return localContainer
    }

    // MARK: - FolderModelのコピー
    func copyFolderModel(
        from localContext: NSManagedObjectContext,
        to cloudLocalContext: NSManagedObjectContext
    ) async throws {
        let fetchRequest: NSFetchRequest<FolderModel> =
            FolderModel.fetchRequest()
        let localItems = try localContext.fetch(fetchRequest)

        for localItem in localItems {
            let request: NSFetchRequest<FolderModel> =
                FolderModel.fetchRequest()
            request.predicate = NSPredicate(
                format: "writeDate == %@",
                localItem.writeDate! as CVarArg
            )

            let existing = try cloudLocalContext.fetch(request)
            if existing.isEmpty {
                print(
                    "✅ コピー作成 : \(localItem.folderIndex). \(localItem.title ?? "Untitled")"
                )
                let newItem = FolderModel(context: cloudLocalContext)
                newItem.title = localItem.title
                newItem.startDate = localItem.startDate
                newItem.finishDate = localItem.finishDate
                newItem.backColor = localItem.backColor
                newItem.writeDate = localItem.writeDate
                newItem.notDaySetting = localItem.notDaySetting
                newItem.lockIsActive = localItem.lockIsActive
                newItem.folderPassword = localItem.folderPassword
                newItem.folderIndex = localItem.folderIndex
            } else {
                print(
                    "⚠️ 重複スキップ: \(localItem.folderIndex). \(localItem.title ?? "Untitled")"
                )
            }
        }
    }

    // MARK: - ListModelのコピー
    func copyListModel(
        from localContext: NSManagedObjectContext,
        to cloudLocalContext: NSManagedObjectContext
    ) async throws {
        let fetchRequest: NSFetchRequest<ListModel> =
            ListModel.fetchRequest()
        let localItems = try localContext.fetch(fetchRequest)

        for localItem in localItems {
            print(
                "✅ コピー作成 : \(localItem.listNumber). \(localItem.text ?? "Untitled")"
            )
            let newItem = ListModel(context: cloudLocalContext)
            newItem.text = localItem.text
            newItem.listNumber = localItem.listNumber
            newItem.category = localItem.category
            newItem.folderDate = localItem.folderDate
            newItem.achievement = localItem.achievement
            newItem.image1 = localItem.image1
            newItem.image2 = localItem.image2
            newItem.miniMemo = localItem.miniMemo
        }
    }

    // MARK: - CategoryEntityのコピー
    func copyCategoryEntity(
        from localContext: NSManagedObjectContext,
        to cloudLocalContext: NSManagedObjectContext
    ) async throws {
        let fetchRequest: NSFetchRequest<CategoryEntity> =
            CategoryEntity.fetchRequest()
        let localItems = try localContext.fetch(fetchRequest)

        for localItem in localItems {
            print(
                "✅ コピー作成 : \(localItem.categoryName ?? "Untitled")"
            )
            let newItem = CategoryEntity(context: cloudLocalContext)
            newItem.categoryAddDate = localItem.categoryAddDate
            newItem.categoryName = localItem.categoryName
        }

    }

    // MARK: - ローカル → iCloud移行
    func migrateLocalToCloud(_ localContext: NSManagedObjectContext)
        async throws
    {
        print("ローカル→iCloud移行開始")
        // iCloudコンテナを開く
        let cloudLocalContainer = try await createLocalContainer(
            "BucketList_Cloud.sqlite"
        )

        let cloudLocalContext = cloudLocalContainer.viewContext
        do {
            // フォルダーのコピー
            try await copyFolderModel(
                from: localContext,
                to: cloudLocalContext
            )

            // リストのコピー
            try await copyListModel(
                from: localContext,
                to: cloudLocalContext
            )

            // カテゴリーのコピー
            try await copyCategoryEntity(
                from: localContext,
                to: cloudLocalContext
            )

            if cloudLocalContext.hasChanges {
                try cloudLocalContext.save()
            }
        } catch {
            cloudLocalContext.rollback()
            print("❌ マイグレーション失敗: \(error)")
            throw error
        }
    }
}
