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
    @Published var startDate = Date()
    @Published var finishDate = Date()
    @Published var backColor = Int16()
    
   
    func addData (context: NSManagedObjectContext) {
        let newFolderData = FolderModel(context:context)
        newFolderData.title = title
        newFolderData.startDate = formattedStartDateString()
        newFolderData.finishDate = finishDate
        newFolderData.backColor = backColor
        
        do { 
            try context.save()
        }
        catch {
            print("新しいフォルダーが作れません")
        }
    }
    
    private var formattedStartDateString : String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.date(from: startDate)
        return formatter.string(from: startDate)
        
    }
}
