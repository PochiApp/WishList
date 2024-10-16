//
//  wishListViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData
import PhotosUI

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
    
    //List関連
    @Published var text = ""
    @Published var listNumber = 0
    @Published var category = ""
    @Published var folderDate = Date()
    @Published var achievement = false
    @Published var datas: [Data] = []
    @Published var image1: Data = Data.init()
    @Published var image2: Data = Data.init()
    @Published var miniMemo = ""
    @Published var images: [UIImage?] = []
    @Published var updateList: ListModel!
    
    //Category関連
    @Published var categoryName = ""
    @Published var categoryAddDate = Date()
    
    //MARK: - Folder関連メソッド
    
    //初アップデート時、folderIndexを既存のFolderに付与する
    func setupFolderIndex (context: NSManagedObjectContext, folders: FetchedResults<FolderModel>) {
        var FolderArray = Array(folders)
        
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
    
    func formattedDateAndTimeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ja_JP")
        formatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd HH:mm:ss")
        return formatter.string(from: date)
    }
    
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
    
    
    //MARK: - Listの新規作成や編集関連メソッド
    
    //Listの新規作成及び編集
    func writeList (context: NSManagedObjectContext) {
        
        //updateListがnilではない場合、Listの編集処理
        if updateList != nil {
            updateList.text = text
            updateList.category = category
            updateList.achievement = achievement
            updateList.image1 = image1
            updateList.image2 = image2
            updateList.miniMemo = miniMemo
            
            try! context.save()
    
            return
        }
        
        //updateListがnilの場合、Listの新規作成処理
        let newListData = ListModel(context:context)
        newListData.text = text
        newListData.listNumber = Int16(listNumber)
        newListData.category = category
        newListData.folderDate = folderDate
        newListData.achievement = false
        newListData.image1 = image1
        newListData.image2 = image2
        newListData.miniMemo = miniMemo
        
        do {
            try context.save()
        }
        catch {
            print("新しいメモが作れません")
        }
    }
    
    //編集するFolderとその内容をセット
    func editList (updateList: ListModel) {
        self.updateList = updateList
        
        text = self.updateList.unwrappedText
        category = self.updateList.unwrappedCategory
        achievement = self.updateList.achievement
        image1 = self.updateList.unwrappedImage1
        image2 = self.updateList.unwrappedImage2
        miniMemo = self.updateList.unwrappedMiniMemo
    }
    
    //ViewModel内のList関連の変数を初期化
    func resetList () {
        updateList = nil
        
        text =  ""
        listNumber = 0
        category = ""
        folderDate = Date()
        achievement = false
        image1 = Data.init()
        image2 = Data.init()
        miniMemo = ""
        
        images = []
    }
    
    //MARK: - Listの画像処理関連メソッド
    func resetImages () {
        datas = []
        images = []
        image1 = Data.init()
        image2 = Data.init()
    }
    
    //PhotosPickerで取得した画像をData型に変換
    func convertDataimages (photos: [PhotosPickerItem]) async {
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            
            DispatchQueue.main.async {
                self.datas.append(data)
            }
        }
    }
    
    //Data型画像 → UIImage型画像に変換
    func convertUiimages () async {
        if !self.images.isEmpty {
            DispatchQueue.main.async {
                self.images.removeAll()
            }
        }
        
        DispatchQueue.main.async {
            guard let uiimage1 = UIImage(data: self.image1) else { print("uiimage失敗1"); return }
            self.images.append(uiimage1)
            
            guard let uiimage2 = UIImage(data: self.image2) else { print("uiimage失敗2");return }
            self.images.append(uiimage2)
        }
    }
    
    //MARK: - カテゴリー関連メソッド
    func setupDefaultCategory(context: NSManagedObjectContext) {
        let newCategoryEntity = CategoryEntity(context: context)
        newCategoryEntity.categoryName = "未分類"
        newCategoryEntity.categoryAddDate = Date()
        
        do {
            try context.save()
        }
        catch {
            print("カテゴリー初期値設定できませんでした")
        }
    }
    
    func addCategory(context: NSManagedObjectContext) {
        let newCategoryEntity = CategoryEntity(context: context)
        newCategoryEntity.categoryName = categoryName
        newCategoryEntity.categoryAddDate = Date()
        
        do {
            try context.save()
        }
        catch {
            print("カテゴリー追加できませんでした")
        }
    }
    
}

