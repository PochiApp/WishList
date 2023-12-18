//
//  FolderViewModel.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/17.
//

import SwiftUI

class FolderViewModel {
    
    var folders: [FolderModels] = []
    
    func addNewFolder(title: String,startDate: String, finishDate: String, backColor: Color) {
        var newFolder = FolderModels(
            title: title,
            startDate: startDate,
            finishDate: finishDate,
            backColor: backColor)
    }
}
