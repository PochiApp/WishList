//
//  FolderViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI
import CoreData

class FolderViewModel : ObservableObject{
    
    @Published var textFieldTitle = ""
    @Published var startDateString = ""
    @Published var finishDateString = ""
    @Published var backColor = Int16()
    
   
    func addNewFolder (context: NSManagedObjectContext) {
        let newFolderData = FolderModel(context:context)
        newFolderData.title = textFieldTitle
        newFolderData.startDateString = startDateString
        newFolderData.finishDateString = finishDateString
        newFolderData.backColor = 7
        
        print(textFieldTitle)
        
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
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
        
    }
}
