//
//  FolderModels.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct FolderModels {
    var title: String
    var startDate: Date
    var finishDate: Date
    var backColor = Color.white
    var backImage : UIImage?
}

struct Colors: Identifiable, Hashable {
    var name: String
    var colorsymbol: String
}
