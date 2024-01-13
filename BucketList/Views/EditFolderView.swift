//
//  EditFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/01/09.
//

import SwiftUI

struct EditFolderView: View {
    
    @Environment (\.managedObjectContext)private var context
    @ObservedObject var folderViewModel: FolderViewModel
    @Binding var isShowEditFolder: Bool
    @State var editTitle: String
    @State var editColor: Int16
    @State var editStartDate: Date
    @State var editFinishDate: Date
    private var foldermodel: FolderModel
    
    
    init(foldermodel: FolderModel, folderViewModel: FolderViewModel, isShowEditFolder: Bool) {
        self.foldermodel = foldermodel
        self.editTitle = foldermodel.title ?? ""
        self.editColor = foldermodel.backColor ?? 0
        self.editStartDate = foldermodel.startDate ?? Date()
        self.editFinishDate = foldermodel.finishDate ?? Date()
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

