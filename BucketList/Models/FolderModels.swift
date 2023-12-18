//
//  FolderModels.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct FolderModels : Identifiable{
    var title: String
    var startDate: String
    var finishDate: String
    var backColor : Color
    var id = UUID()
}
