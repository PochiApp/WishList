//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData

struct FolderView: View {
    
    @Environment(\.managedObjectContext) private var context
    @AppStorage ("isFirstLaunchKey") var launchKey = false
    
    @FetchRequest(
        entity: FolderModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FolderModel.writeDate, ascending: false)],
        animation: .default)
        private var folderModel: FetchedResults<FolderModel>
    
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var isShowListView = false
    @State var isShowFolderWrite: Bool = false
    @State var isShowPassInputPage: Bool = true
    @State var isShowSetPassPage: Bool = false
    @State var isShowUnlockPassPage: Bool = false
    
    
    var body: some View {
        NavigationStack {
                ZStack {
                    Color.gray.opacity(0.08).edgesIgnoringSafeArea(.all)
                    if folderModel.isEmpty {
                        emptyFolderView
                    }
                    
                    folderArea
                        
                        
                    VStack {
                        Spacer()
                            HStack {
                                Spacer()
                                    
                                floatingButton
                                }
                            }

                        .navigationBarBackButtonHidden(true)
                        
                    }
        }
            .onAppear(perform: {
                isShowPassInputPage = true
                self.context.refreshAllObjects()
                
                    if launchKey == false {
                        bucketViewModel.setupDefaultCategory(context: context)
                            launchKey = true
                        }
            })

        }
}

extension FolderView {

    private var folderArea: some View {
        ScrollView(.vertical, showsIndicators: false){
            Spacer()
            
            ForEach(folderModel){ foldermodel in
                NavigationLink(destination: ListView(bucketViewModel: bucketViewModel, selectedFolder: foldermodel, isShowPassInputPage: $isShowPassInputPage)){
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("\(foldermodel.unwrappedBackColor)"))
                        .frame(width: 290, height: 150)
                        .shadow(color: .gray.opacity(0.9), radius: 1, x: 2, y: 2)
                        .overlay(
                            VStack(alignment: .center){
                                Text(foldermodel.notDaySetting ? "" : "\(bucketViewModel.formattedDateString(date: foldermodel.unwrappedStartDate)) ~ \(bucketViewModel.formattedDateString(date: foldermodel.unwrappedFinishDate))")
                                    .font(.system(size: 16))
                                    .padding(.top)
                                HStack {
                                    if foldermodel.lockIsActive {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 14))
                                            .padding(.top)
                                    }
                                        Text("\(foldermodel.unwrappedTitle)")
                                            .lineLimit(2)
                                            .font(.system(size: 17, weight: .semibold))
                                            .padding(.top)
                                       
                                }
                                
                                if let listsAchieved = foldermodel.achievedLists, let allLists = foldermodel.lists {
                                    Text("達成：\(listsAchieved.count)/\(allLists.count)")
                                        .font(.system(size: 11))
                                        .padding(.top, 6)
                                }
                                
                                
                                
                            }
                                .foregroundColor(Color("originalBlack"))
                            , alignment: .top
                        )
                    
                    
                }
                .contextMenu(ContextMenu(menuItems: {
                    if foldermodel.lockIsActive {
                        Button(action: {
                            bucketViewModel.lockFolder = foldermodel
                            isShowUnlockPassPage = true
                
                        }, label: {
                            Text("フォルダーのロック解除")
                        })
                        
                            
                    } else {
                        Button(action: {

                            bucketViewModel.lockFolder = foldermodel
                            isShowSetPassPage = true
                        
                        }, label: {
                            Text("フォルダーをロック")
                        })
                        }
                        
                    
                    Button(action: {
                        bucketViewModel.editFolder(upFolder: foldermodel)
                        isShowFolderWrite.toggle()
                        
                    }, label: {
                        Text("編集")
                    })
                    .sheet(isPresented: $isShowFolderWrite) {
                        
                        WriteFolderView(bucketViewModel : bucketViewModel, isShowFolderWrite: $isShowFolderWrite)
                            .presentationDetents([.large])
                    }
                    .fullScreenCover(isPresented: $isShowSetPassPage, content: {
                        SetPassView(bucketViewModel: bucketViewModel, isShowSetPassPage: $isShowSetPassPage, isShowUnlockPassPage: $isShowUnlockPassPage)

                    })
                    
                    .sheet(isPresented: $isShowUnlockPassPage) {
                        SetPassView(bucketViewModel: bucketViewModel, isShowSetPassPage: $isShowSetPassPage, isShowUnlockPassPage: $isShowUnlockPassPage)
                            .presentationDetents([.large])
                    }
                    
                    Button(action: {
                        withAnimation {
                            context.delete(foldermodel)
                        }
                        try? context.save()
                    }, label: {
                        Text("削除")
                    })
                }))
                .transition(
                    AnyTransition.asymmetric(insertion: AnyTransition.slide.combined(with: AnyTransition.opacity), removal: AnyTransition.identity))
                
                
            }
        }
    }
    
    
    private var floatingButton: some View {
        Button(action: {
            isShowFolderWrite.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color("originalBlack"))
                .shadow(color: .gray.opacity(0.9), radius: 3)
                .font(.system(size: 40))
            
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 50))
        .sheet(isPresented: $isShowFolderWrite){
            
            WriteFolderView(bucketViewModel: bucketViewModel, isShowFolderWrite: $isShowFolderWrite)
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
