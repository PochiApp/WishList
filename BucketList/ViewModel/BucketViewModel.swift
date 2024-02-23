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
    @Published var backColor = 0
    @Published var updateFolder: FolderModel!
    
    @Published var notDaySetting = false
    
    @Published var text = ""
    @Published var listNumber = 0
    @Published var category = ""
    @Published var folderDate = Date()
    @Published var achievement = false
    @Published var datas: [Data] = []
    @Published var image1: Data = Data.init()
    @Published var image2: Data = Data.init()
    @Published var images: [UIImage?] = []
    @Published var updateList: ListModel!
    
    @AppStorage ("isFirstCategory") var firstCategory = "未分類"
    
    @Published var categoryName = ""
    @Published var categoryAddDate = Date()
    
    
    let colorList: [Color] = [.white,
                              .red.opacity(0.7),
                              .orange.opacity(0.5),
                              .yellow.opacity(0.5),
                              .green.opacity(0.5),
                              .mint.opacity(0.5),
                              .teal.opacity(0.5),
                              .cyan.opacity(0.6),
                              .blue.opacity(0.5),
                              .indigo.opacity(0.5),
                              .purple.opacity(0.5),
                              .pink.opacity(0.2),
                              .brown.opacity(0.5),
                              .gray.opacity(0.3)]
    
    
   
    func writeFolder (context: NSManagedObjectContext) {
        
        if updateFolder != nil {
            
            updateFolder.title = title
            updateFolder.notDaySetting = notDaySetting
            updateFolder.startDate = selectedStartDate
            updateFolder.finishDate = selectedFinishDate
            updateFolder.backColor = Int16(backColor)
            
            try! context.save()
            
            updateFolder = nil
            
            title = ""
            notDaySetting = false
            selectedStartDate = Date()
            selectedFinishDate = Date()
            backColor = 0
            
            return
        }
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
        newFolderData.notDaySetting = notDaySetting
        newFolderData.startDate = selectedStartDate
        newFolderData.finishDate = selectedFinishDate
        newFolderData.backColor = Int16(backColor)
        newFolderData.writeDate = Date()
        
        do {
            try context.save()
            
            title = ""
            notDaySetting = false
            selectedStartDate = Date()
            selectedFinishDate = Date()
            backColor = 0
           
        }
        catch {
            print("新しいフォルダーが作れません")
        }
    }
    
    func formattedDateString(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier:"ja_JP")
            formatter.dateFormat = "yyyy/MM/dd"
            return formatter.string(from: date)
    }
    
    func editFolder (upFolder: FolderModel) {
        updateFolder = upFolder
        
        title = updateFolder.title ?? ""
        notDaySetting = updateFolder.notDaySetting
        selectedStartDate = updateFolder.startDate ?? Date()
        selectedFinishDate = updateFolder.finishDate ?? Date()
        backColor = Int(updateFolder.backColor)
        
        
    }
    
    func resetFolder () {
        
        updateFolder = nil
        
        title =  ""
        notDaySetting = false
        selectedStartDate =  Date()
        selectedFinishDate = Date()
        backColor = 0
        
    }
    
    func writeList (context: NSManagedObjectContext) {
        
        if updateList != nil {
            updateList.text = text
            updateList.category = category
            updateList.achievement = achievement
            updateList.image1 = image1
            updateList.image2 = image2
            
            try! context.save()
            
            text = ""
            category = firstCategory
            achievement = false
            image1 = Data.init()
            image2 = Data.init()
            
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
        
        do {
            try context.save()
            
            text = ""
            listNumber = 0
            category = firstCategory
            folderDate = Date()
            achievement = false
            image1 = Data.init()
            image2 = Data.init()
            
        }
        catch {
            print("新しいメモが作れません")
        }
        
        
    }
    
    func editList (upList: ListModel) {
        updateList = upList
        
        text = updateList.text ?? ""
        category = updateList.category ?? ""
        achievement = updateList.achievement
        image1 = updateList.image1 ?? Data.init()
        image2 = updateList.image2 ?? Data.init()
        
    }
    
    func resetList () {
        
        updateList = nil
        
        text =  ""
        listNumber = 0
        category = firstCategory
        folderDate = Date()
        achievement = false
        image1 = Data.init()
        image2 = Data.init()
        
        images = []
        
    }
    
    func convertDataimages (photos: [PhotosPickerItem]) async {
        
    var newDatas: [Data] = []
        
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            newDatas.append(data)
        }
        
        let appendData = Array(Set(newDatas))
        
            DispatchQueue.main.async {
                print("最初\(appendData.count)")
                self.datas.append(contentsOf: appendData)
                print("3")
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
                print("ui1 : \(uiimage1)")
                guard let uiimage2 = UIImage(data: self.image2) else { print("uiimage失敗2");return }
                self.images.append(uiimage2)
                print("ui2 : \(uiimage2)")
                

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
            
            categoryName = ""
            
        }
        catch {
            print("カテゴリー追加できませんでした")
        }
    }
    
    
}

