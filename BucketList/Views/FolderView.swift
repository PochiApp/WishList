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
        private var fm: FetchedResults<FolderModel>
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var isShowListView = false
    @State var isShowFolderWrite: Bool = false
    @State var isShowUnlockAlert: Bool = false
    @State var isShowMissAlert: Bool = false
    @State var isShowPassAlert: Bool = false
    @State var isShowPassInputPage: Bool = true
    
    
    var body: some View {
        NavigationStack {
                ZStack {
                    Color.gray.opacity(0.08).edgesIgnoringSafeArea(.all)
                    if fm.isEmpty {
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
            
            
            ForEach(fm){foldermodel in
                NavigationLink(destination: ListView(bucketViewModel: bucketViewModel, selectedFolder: foldermodel, isShowPassInputPage: $isShowPassInputPage)){
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("\(foldermodel.unwrappedBackColor)"))
                        .frame(width: 300, height: 150)
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
                                
                                Text("達成：\(foldermodel.unwrappedAchievedLists.count)/\(foldermodel.unwrappedLists.count)")
                                    .font(.system(size: 11))
                                    .padding(.top, 6)
                                
                                
                            }
                                .foregroundColor(.black)
                            , alignment: .top
                        )
                    
                    
                }
                .onAppear {
                    self.context.refreshAllObjects()
                    bucketViewModel.category = bucketViewModel.firstCategory
                }
                .contextMenu(ContextMenu(menuItems: {
                    
                    if foldermodel.lockIsActive {
                        Button(action: {
                            isShowUnlockAlert.toggle()
                        }, label: {
                            Text("フォルダーのロック解除")
                        })
                    } else {
                        Button(action: {
                            isShowPassAlert.toggle()
                        }, label: {
                            Text("フォルダーをロック")
                        })
                    }
                    
                    Button(action: {
                        isShowFolderWrite.toggle()
                        bucketViewModel.editFolder(upFolder: foldermodel)
                    }, label: {
                        Text("編集")
                    })
                    .sheet(isPresented: $isShowFolderWrite) {
                        
                        WriteFolderView(bucketViewModel : bucketViewModel, isShowFolderWrite: $isShowFolderWrite)
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
                .alert("ロックの解除", isPresented: $isShowUnlockAlert) {
                    SecureField("パスワード", text: $bucketViewModel.folderPassword)
                    
                    Button("Cancel") {
                        isShowUnlockAlert = false
                        bucketViewModel.folderPassword = ""
                    }
                    
                    Button("確認") {
                        if foldermodel.folderPassword == bucketViewModel.folderPassword {
                            bucketViewModel.unLockFolder(lockFolder: foldermodel, context: context)
                        } else {
                            isShowMissAlert = true
                            bucketViewModel.folderPassword = ""
                        }
                    }
                    
                } message: {
                    
                    Text("設定しているパスワードを入力してください")
                }
                .alert("パスワードが間違っています", isPresented: $isShowMissAlert) {
                    
                    Button("OK") {
                        isShowMissAlert = false
                        isShowUnlockAlert = true
                    }
                        
                } message: {
                    Text("正しいパスワードを入力してください。")
                }
                
                .alert("フォルダーをロック", isPresented: $isShowPassAlert) {
                    SecureField("パスワード", text: $bucketViewModel.folderPassword)
                    
                    Button("Cancel") {
                        isShowPassAlert = false
                        bucketViewModel.folderPassword = ""
                    }
                    
                    Button("OK") {
                        bucketViewModel.lockFolder(lockFolder: foldermodel, context: context)
                    }
                        
                } message: {
                    Text("パスワードを設定してください")
                }
            }
        }
        
    }
    
    
    private var floatingButton: some View {
        Button(action: {
            isShowFolderWrite.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
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

