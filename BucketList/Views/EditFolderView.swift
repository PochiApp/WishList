//
//  EditFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/01/09.
//

import SwiftUI

struct EditFolderView: View {
    
    @Environment (\.managedObjectContext)private var context
    @ObservedObject var folderViewModel : FolderViewModel
    
    
    init()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

