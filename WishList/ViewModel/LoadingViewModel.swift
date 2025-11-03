//
//  LoadingViewModel.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/11/01.
//

import CloudKit
import CoreData
import SwiftUI

class LoadingViewModel: ObservableObject {
    private var observer: NSObjectProtocol?

    func startCloudSync(_ container: NSPersistentCloudKitContainer) async {
        await withCheckedContinuation { continuation in
            observer = NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: container.persistentStoreCoordinator,
                queue: .main
            ) { _ in
                print("☁️ Cloud → Local 同期完了検知")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .cloudSyncCompleted,
                        object: nil
                    )
                    if let obs = self.observer {
                        NotificationCenter.default.removeObserver(obs)
                        self.observer = nil
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    @MainActor
    func waitUntilFetched(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<FolderModel>(entityName: "FolderModel")
        for _ in 0..<200 { // 最大10秒（0.1秒×200回）
            do {
                let count = try context.count(for: request)
                if count > 0 {
                    print("✅ フェッチ結果確認: \(count) 件")
                    return
                }
            } catch {
                print("フェッチ失敗: \(error)")
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒待機
        }
        print("⚠️ フェッチタイムアウト（0件）")
    }
}
