//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData
import UIKit

struct FolderView: View {
    
    @Environment(\.managedObjectContext) private var context
    @AppStorage ("isFirstLaunchKey") var launchKey = false  //初回起動したかのフラグをUserDefaultで保存
    
    //
    @FetchRequest(
        entity: FolderModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FolderModel.writeDate, ascending: false)],
        animation: .default)
    private var folderModel: FetchedResults<FolderModel>
    
    @ObservedObject var wishListViewModel : WishListViewModel
    @State var isShowListView = false
    @State var isShowAddAndEditFolderView: Bool = false
    
    //Folderロック機能関係のフラグ
    @State var isInsertPassViewBeforeListView: Bool = true //PassViewで正しいパスコードが入力されたらfalseになる。デフォルトはtrue
    @State var isShowSetPassView: Bool = false
    @State var isShowUnlockPassView: Bool = false
    
    
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
            if launchKey == false {
                wishListViewModel.setupDefaultCategory(context: context)
                launchKey = true
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
                NavigationLink(destination:ListView(wishListViewModel: wishListViewModel, selectedFolder: foldermodel, isInsertPassViewBeforeListView: $isInsertPassViewBeforeListView)){
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("\(foldermodel.unwrappedBackColor)"))
                        .frame(width: 290, height: 150)
                        .shadow(color: .gray.opacity(0.9), radius: 1, x: 2, y: 2)
                        .overlay(
                            VStack(alignment: .center){
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
                //パスコード設定画面の表示
                .fullScreenCover(isPresented: $isShowSetPassView, content: {
                    SetPassView(wishListViewModel: wishListViewModel, isShowSetPassView: $isShowSetPassView, isShowUnlockPassView: $isShowUnlockPassView)
                })
                
                //Folderアンロック時のパスコード入力画面の表示
                .fullScreenCover(isPresented: $isShowUnlockPassView, content: {
                    SetPassView(wishListViewModel: wishListViewModel, isShowSetPassView: $isShowSetPassView, isShowUnlockPassView: $isShowUnlockPassView)
                        .presentationDetents([.large])
                })
                .transition(
                    AnyTransition.asymmetric(insertion: AnyTransition.slide.combined(with: AnyTransition.opacity), removal: AnyTransition.identity))
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
