//
//  FolderViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData

class FolderViewModel : ObservableObject{
    
    @Published var title = ""
    @Published var selectedStartDate = Date()
    @Published var selectedFinishDate = Date()
    @Published var backColor = 0
    
    @State var startDateString = ""
    @State var finishDateString = ""
    
   
    func addNewFolder (context: NSManagedObjectContext) {
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
        newFolderData.startDate = selectedStartDate
        newFolderData.finishDate = selectedFinishDate
        newFolderData.backColor = NSNumber(value: backColor)
        
        do {
            try context.save()
        }
        catch {
            print("新しいフォルダーが作れません")
        }
    }
    
    private func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
        
    }
    
    func editFolder (updateFolder: FolderModel) {
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
        newFolderData.startDateString = formattedDateString(date: selectedStartDate)
        newFolderData.finishDateString = formattedDateString(date: selectedFinishDate)
        newFolderData.backColor = NSNumber(value: backColor)
        
        do {
            try context.save()
        }
        catch {
            print("新しいフォルダーが作れません")
        }
    }
}
