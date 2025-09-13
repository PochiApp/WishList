//
//  wishListViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData

class WishListViewModel : ObservableObject{
    
    //Folder関連
    @Published var folderTitle = ""
    @Published var selectedStartDate: Date = Date()
    @Published var selectedFinishDate: Date = Date()
    @Published var backColor = "snowWhite"
    @Published var updateFolder: FolderModel! //編集対象のフォルダーが格納される
    @Published var lockIsAcctive = false
    @Published var folderPassword = ""
    @Published var notDaySetting = false //フォルダーの期日設定なしの場合true
    @Published var lockFolder: FolderModel! //ロック対象のフォルダーが格納される
    
//    //List関連
//    @Published var text = ""
//    @Published var listNumber = 0
//    @Published var category = ""
//    @Published var folderDate = Date()
//    @Published var achievement = false
//    @Published var datas: [Data] = []
//    @Published var image1: Data = Data.init()
//    @Published var image2: Data = Data.init()
//    @Published var miniMemo = ""
//    @Published var images: [UIImage?] = []
//    @Published var updateList: ListModel!
    
//    //Category関連
//    @Published var categoryName = ""
//    @Published var categoryAddDate = Date()
    
    //MARK: - Folder関連メソッド
    
    //初アップデート時、folderIndexを既存のFolderに付与する
    func setupFolderIndex (context: NSManagedObjectContext, folders: FetchedResults<FolderModel>) {
        let FolderArray = Array(folders)
        
        //ソート機能で昇順と降順で並び替えられている場合で、indexの変更方法を分岐
        for index in stride(from: FolderArray.count - 1, through: 0, by: -1){
            FolderArray[index].folderIndex = Int16(index + 1)
        }
        do {
            try context.save()
            print("\(FolderArray)")
        }
        catch {
            print("folderIndex更新失敗")
        }
            
    }
    
    //Folderの新規作成及び編集
    func addNewFolderOrEditFolder (context: NSManagedObjectContext) {
        
        //updateFolderがnilではない場合、Folderの編集処理
        if updateFolder != nil {
            updateFolder.title = folderTitle
            updateFolder.notDaySetting = notDaySetting
            updateFolder.startDate = selectedStartDate
            updateFolder.finishDate = selectedFinishDate
            updateFolder.backColor = backColor
            
            try! context.save()
            
            return
        }
        
        //新規フォルダーのfolderIndexを0として挿入するため、既存のフォルダーのfolderIndexを+1に変更
        let fetchRequest: NSFetchRequest<FolderModel> = FolderModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FolderModel.folderIndex, ascending: true)]
        
        if let results = try? context.fetch(fetchRequest) {
            for (index, folder) in results.enumerated() {
                folder.folderIndex = Int16(index + 1)
            }
        }
        //updateFolderがnilの場合、Folderの新規作成処理
        let newFolderData = FolderModel(context:context)
        newFolderData.title = folderTitle
        newFolderData.notDaySetting = notDaySetting
        newFolderData.startDate = selectedStartDate
        newFolderData.finishDate = selectedFinishDate
        newFolderData.backColor = backColor
        newFolderData.writeDate = Date()
        
        do {
            try context.save()
        }
        catch {
            print("新しいフォルダーが作れません")
        }
    }
    
    func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ja_JP")
        formatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd")
        return formatter.string(from: date)
    }
    
//    func formattedDateAndTimeString(date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier:"ja_JP")
//        formatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd HH:mm:ss")
//        return formatter.string(from: date)
//    }
    
    //編集するFolderとその内容をセット
    func editFolder (updateFolder: FolderModel) {
        self.updateFolder = updateFolder
        
        folderTitle = self.updateFolder.unwrappedTitle
        notDaySetting = self.updateFolder.notDaySetting
        selectedStartDate = self.updateFolder.unwrappedStartDate
        selectedFinishDate = self.updateFolder.unwrappedFinishDate
        backColor = self.updateFolder.unwrappedBackColor
    }
    
    func lockFolder(context: NSManagedObjectContext) {
        lockFolder.lockIsActive = true
        lockFolder.folderPassword = folderPassword
        
        try! context.save()
        
        folderPassword = ""
    }
    
    func unLockFolder(context: NSManagedObjectContext) {
        lockFolder.lockIsActive = false
        lockFolder.folderPassword = ""
        
        try! context.save()
        
        folderPassword = ""
    }
    
    //ViewModel内のFolder関連の変数を初期化
    func resetFolder () {
        updateFolder = nil
        
        folderTitle =  ""
        notDaySetting = false
        selectedStartDate =  Date()
        selectedFinishDate = Date()
        backColor = "snowWhite"
    }
    
    
    //カテゴリー初期化処理 未分類廃止
//    func setupDefaultCategory(context: NSManagedObjectContext) {
//        let newCategoryEntity = CategoryEntity(context: context)
//        newCategoryEntity.categoryName = "未分類"
//        newCategoryEntity.categoryAddDate = Date()
//        
//        do {
//            try context.save()
//        }
//        catch {
//            print("カテゴリー初期値設定できませんでした")
//        }
//    }
}

