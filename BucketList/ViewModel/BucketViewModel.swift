//
//  BucketViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData

class BucketViewModel : ObservableObject{
    
    @Published var title = ""
    @Published var selectedStartDate: Date = Date()
    @Published var selectedFinishDate: Date = Date()
    @Published var backColor = 0
    @Published var updateFolder: FolderModel!
    
    @State var startDateString = ""
    @State var finishDateString = ""
    
    @Published var text = ""
    @Published var listNumber = 0
    @Published var category = ""
    @Published var folderDate = Date()
    @Published var achievement = false
    
    
   
    func writeFolder (context: NSManagedObjectContext) {
        
        if updateFolder != nil {
            
            updateFolder.title = title
            updateFolder.startDate = selectedStartDate
            updateFolder.finishDate = selectedFinishDate
            updateFolder.backColor = Int16(backColor)
            
            try! context.save()
            
            updateFolder = nil
            
            title = ""
            selectedStartDate = Date()
            selectedFinishDate = Date()
            backColor = 0
            
            return
        }
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
        newFolderData.startDate = selectedStartDate
        newFolderData.finishDate = selectedFinishDate
        newFolderData.backColor = Int16(backColor)
        newFolderData.writeDate = Date()
        
        do {
            try context.save()
            
            title = ""
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
        selectedStartDate = updateFolder.startDate ?? Date()
        selectedFinishDate = updateFolder.finishDate ?? Date()
        backColor = Int(updateFolder.backColor)
        
        
    }
    
    func resetFolder () {
        
        title =  ""
        selectedStartDate =  Date()
        selectedFinishDate = Date()
        backColor = 0
        
    }
    
    func writeList (context: NSManagedObjectContext) {
        
        let newListData = ListModel(context:context)
        newListData.text = text
        newListData.listNumber = Int16(listNumber)
        newListData.category = category
        newListData.folderDate = folderDate
        newListData.achievement = false
        
        do {
            try context.save()
        }
        catch {
            print("新しいメモが作れません")
        }
        
        
    }

}
