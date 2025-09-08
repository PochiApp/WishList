//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData
import UIKit
import UniformTypeIdentifiers

struct FolderView: View {
    
    @Environment(\.managedObjectContext) private var context
    //初回起動したかのフラグをUserDefaultで保存
    @AppStorage("isFirstLaunchKey") var launchKey = false
    
    @AppStorage("isUpdateDataModel") var isUpdateDataModel = false
    
    @FetchRequest(
        entity: FolderModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FolderModel.folderIndex, ascending: true)],
        animation: .default)
    private var folderModel: FetchedResults<FolderModel>
    
    @StateObject var wishListViewModel: WishListViewModel = WishListViewModel()
    @State var isShowListView: Bool = false
    @State var isShowAddAndEditFolderView: Bool = false
    
    //Folderロック機能関係のフラグ
    @State var isInsertPassViewBeforeListView: Bool = true //PassViewで正しいパスコードが入力されたらfalseになる。デフォルトはtrue
    @State var isShowSetPassView: Bool = false
    @State var isShowUnlockPassView: Bool = false
    
    @State var currentFolder: FolderModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                //背景色を薄目のグレーに設定。白色のフォルダーの境界が分かるようにする必要あり
                Color.gray.opacity(0.08).edgesIgnoringSafeArea(.all)
                
                if folderModel.isEmpty {
                    emptyFolderView
                }
                
                VStack {
                    folderArea
                        .navigationBarBackButtonHidden(true)
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        floatingButton
                    }
                }
            }
        }
        .onAppear(perform: {
            //Folder画面に戻ったらこのフラグをtrueに初期化して、再度PassViewが表示されるようにする
            isInsertPassViewBeforeListView = true
            
            //List更新後、達成率が反映するように再度fetchが必要
            self.context.refreshAllObjects()
            
            //初回起動時のみCategoryを"未分類"のみに初期設定
//            if launchKey == false {
//                wishListViewModel.setupDefaultCategory(context: context)
//                launchKey = true
//            }
            
            if (launchKey == true && isUpdateDataModel == false) {
                wishListViewModel.setupFolderIndex(context: context, folders: folderModel)
                isUpdateDataModel = true
            }
        })
    }
}

//MARK: - extension
extension FolderView {
    private var folderArea: some View {
        ScrollView(.vertical, showsIndicators: false){
            Spacer()
            
            ForEach(folderModel){ foldermodel in
                NavigationLink(destination:ListView(selectedFolder: foldermodel, isInsertPassViewBeforeListView: $isInsertPassViewBeforeListView)){
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("\(foldermodel.unwrappedBackColor)"))
                        .opacity(currentFolder == foldermodel ? 0.8 : 1.0)
                        .frame(width: 280, height: 150)
                        .shadow(color: .gray.opacity(0.9), radius: 1, x: 2, y: 2)
                        .overlay(
                            LazyVStack(alignment: .center){
                                //Folder期日表示部分
                                Text(foldermodel.notDaySetting ? "" : "\(wishListViewModel.formattedDateString(date: foldermodel.unwrappedStartDate)) ~ \(wishListViewModel.formattedDateString(date: foldermodel.unwrappedFinishDate))")
                                    .font(.system(size: 16))
                                    .padding(.top)
                                
                                HStack {
                                    //Folderロック機能がONなら、キーマークを表示
                                    if foldermodel.lockIsActive {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 14))
                                            .padding(.top)
                                    }
                                    
                                    //Folderのタイトル表示部分
                                    Text("\(foldermodel.unwrappedTitle)")
                                        .lineLimit(2)
                                        .font(.system(size: 17, weight: .semibold))
                                        .padding(.top)
                                }
                                
                                //リスト達成率表示部分
                                if let listsAchieved = foldermodel.achievedLists, let allLists = foldermodel.lists {
                                    Text("達成：\(listsAchieved.count)/\(allLists.count)")
                                        .font(.system(size: 11))
                                        .padding(.top, 6)
                                }
                            }
                                .foregroundColor(Color("originalBlack"))
                                //このalignmentを設定しないと、Folder内の文字が全体的に下へいってしまう
                                , alignment: .top
                        )
                }
                //長押しで表示するMenu部分
                .contextMenu(ContextMenu(menuItems: {
                    if foldermodel.lockIsActive {
                        Button(action: {
                            wishListViewModel.lockFolder = foldermodel
                            isShowUnlockPassView = true
                        }, label: {
                            Label("フォルダーのロック解除", systemImage: "lock.open")
                        })
                    } else {
                        Button(action: {
                            wishListViewModel.lockFolder = foldermodel
                            isShowSetPassView = true
                        }, label: {
                            Label("フォルダーをロック", systemImage: "lock")
                        })
                    }
                    
                    Button(action: {
                        wishListViewModel.editFolder(updateFolder: foldermodel)
                        isShowAddAndEditFolderView.toggle()
                    }, label: {
                        Label("編集", systemImage: "pencil")
                    })
                    .sheet(isPresented: $isShowAddAndEditFolderView) {
                        AddAndEditFolderView(wishListViewModel : wishListViewModel, isShowAddAndEditFolderView: $isShowAddAndEditFolderView)
                            .presentationDetents([.large])
                    }
                    
                    Button(action: {
                        withAnimation {
                            context.delete(foldermodel)
                        }
                        try? context.save()
                    }, label: {
                        Label("削除", systemImage: "trash")
                    })
                }))
                .onDrag{
                    currentFolder = foldermodel
                    let draggedFolder = String(currentFolder?.folderIndex ?? Int16(0))
                    return NSItemProvider(object: draggedFolder as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DropViewDelegate(dropFolder: foldermodel, folders: folderModel, currentDragFolder: currentFolder, context: context, wishListViewModel: wishListViewModel))
                //パスコード設定画面の表示
                .fullScreenCover(isPresented: $isShowSetPassView, content: {
                    SetPassView(wishListViewModel: wishListViewModel, isShowSetPassView: $isShowSetPassView, isShowUnlockPassView: $isShowUnlockPassView)
                })
                
                //Folderアンロック時のパスコード入力画面の表示
                .fullScreenCover(isPresented: $isShowUnlockPassView, content: {
                    SetPassView(wishListViewModel: wishListViewModel, isShowSetPassView: $isShowSetPassView, isShowUnlockPassView: $isShowUnlockPassView)
                        .presentationDetents([.large])
                })
            }
        }
    }
    
    private var floatingButton: some View {
        Button(action: {
            isShowAddAndEditFolderView.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color("originalBlack"))
                .shadow(color: .gray.opacity(0.9), radius: 3)
                .font(.system(size: 40))
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 50))
        .sheet(isPresented: $isShowAddAndEditFolderView){
            AddAndEditFolderView(wishListViewModel: wishListViewModel, isShowAddAndEditFolderView: $isShowAddAndEditFolderView)
                .presentationDetents([.large, .fraction(0.9)])
        }
    }
    
    private var emptyFolderView: some View {
        VStack(alignment: .center) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 100))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.bottom)
            
            Text("右下＋ボタンから、フォルダーを新規作成してみましょう")
                .font(.caption)
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }
}

extension UIScrollView {
    open override var clipsToBounds: Bool {
        get { false }
        set { }
    }
}

struct DropViewDelegate: DropDelegate {
    var dropFolder: FolderModel
    var folders: FetchedResults<FolderModel>
    var currentDragFolder: FolderModel!
    var context: NSManagedObjectContext
    @ObservedObject var wishListViewModel : WishListViewModel
    
    
    func performDrop(info: DropInfo) -> Bool {
        do {
            try context.save()
        }
        catch {
            print("移動後の順序保存失敗")
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let dragedFolder = currentDragFolder else { return }
        
        if dragedFolder != dropFolder {
            withAnimation(.default) {
                let fromIndex = folders.firstIndex(of: dragedFolder)!
                let toIndex = folders.firstIndex(of: dropFolder)!
                
                var folderModelsArray = Array(folders)
                
                folderModelsArray.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                
                for (index, folder) in folderModelsArray.enumerated() {
                    folder.folderIndex = Int16(index)
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}



