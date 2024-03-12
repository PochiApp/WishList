//
//  BucketViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData
import PhotosUI

class BucketViewModel : ObservableObject{
    
    @Published var title = ""
    @Published var selectedStartDate: Date = Date()
    @Published var selectedFinishDate: Date = Date()
    @Published var backColor = "snowWhite"
    @Published var updateFolder: FolderModel!
    @Published var lockIsAcctive = false
    @Published var folderPassword = ""
    @Published var notDaySetting = false
    @Published var lockFolder: FolderModel!
    
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
    
    @Published var categoryName = ""
    @Published var categoryAddDate = Date()
    
   
    func writeFolder (context: NSManagedObjectContext) {
        
        if updateFolder != nil {
            
            updateFolder.title = title
            updateFolder.notDaySetting = notDaySetting
            updateFolder.startDate = selectedStartDate
            updateFolder.finishDate = selectedFinishDate
            updateFolder.backColor = backColor
            
            try! context.save()
            
            return
        }
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
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
    
    func editFolder (upFolder: FolderModel) {
        updateFolder = upFolder
        
        title = updateFolder.unwrappedTitle
        notDaySetting = updateFolder.notDaySetting
        selectedStartDate = updateFolder.unwrappedStartDate
        selectedFinishDate = updateFolder.unwrappedFinishDate
        backColor = updateFolder.unwrappedBackColor
        
        
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
    
    func resetFolder () {
        
        updateFolder = nil
        
        title =  ""
        notDaySetting = false
        selectedStartDate =  Date()
        selectedFinishDate = Date()
        backColor = "snowWhite"
        
    }
    
    func writeList (context: NSManagedObjectContext) {
        
        if updateList != nil {
            updateList.text = text
            updateList.category = category
            updateList.achievement = achievement
            updateList.image1 = image1
            updateList.image2 = image2
            updateList.miniMemo = miniMemo
            
            try! context.save()
            
            updateList = nil
            
            text = ""
            category = ""
            achievement = false
            image1 = Data.init()
            image2 = Data.init()
            miniMemo = ""
            
            return
            
        }
        
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
    
    func editList (upList: ListModel) {
        updateList = upList
        
        text = updateList.unwrappedText
        category = updateList.unwrappedCategory
        achievement = updateList.achievement
        image1 = updateList.unwrappedImage1
        image2 = updateList.unwrappedImage2
        miniMemo = updateList.unwrappedMiniMemo
        
    }
    
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
    
    func resetImages () {
        datas = []
        images = []
        image1 = Data.init()
        image2 = Data.init()
    }
    
    func convertDataimages (photos: [PhotosPickerItem]) async {
        
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            
            DispatchQueue.main.async {
                
                self.datas.append(data)
              
            }
        }
        
            
            
    }

    
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

