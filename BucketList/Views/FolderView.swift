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
    
    
    var body: some View {
            ZStack {
                NavigationStack{
                        
                        folderArea
                    VStack {
                        HStack {
                            Spacer()
                            
                            floatingButton
                        }
                    }

                        }
                .navigationBarBackButtonHidden(true)
                .onAppear(perform: {
                    if launchKey == false {
                        bucketViewModel.setupDefaultCategory(context: context)
                        
                        launchKey = true
                    }
                    
                    
                })
                    }
        
        
        
             }
        
        }



extension FolderView {
    
    
    private var folderArea: some View {
        ScrollView(.vertical, showsIndicators: false){
            Spacer()
            

                ForEach(fm){foldermodel in
                    NavigationLink(destination: ListView(bucketViewModel: bucketViewModel, selectedFolder: foldermodel)){
                        RoundedRectangle(cornerRadius: 16)
                            .fill(bucketViewModel.colorList[Int(foldermodel.backColor)])
                            .frame(width: 300, height: 150)
                            .shadow(color: .gray, radius: 5, x: 5, y: 5)
                            .overlay(
                                VStack(alignment: .center){
                                    Text(foldermodel.notDaySetting ? "" : "\(bucketViewModel.formattedDateString(date: foldermodel.unwrappedStartDate)) ~ \(bucketViewModel.formattedDateString(date: foldermodel.unwrappedFinishDate))")
                                        .font(.system(size: 16))
                                        .padding(.top)
                                    Text("\(foldermodel.unwrappedTitle)")
                                        .lineLimit(2)
                                        .font(.system(size: 18, weight: .semibold))
                                        .padding(.top)
                                    Text("達成：\(foldermodel.unwrappedAchievedLists.count)/\(foldermodel.unwrappedLists.count)")
                                        .padding(.top)
                                        .font(.system(size: 11))
                                    
                                }
                                    .foregroundColor(.black)
                                , alignment: .top
                            )
                        
                        
                    }
                    .onAppear {
                        self.context.refreshAllObjects()
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: {
                            withAnimation {
                                context.delete(foldermodel)
                            }
                            try? context.save()
                        }, label: {
                            Text("削除")
                        })
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
                .foregroundColor(.black)
                .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                .font(.system(size: 40))
                
        })
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 50))
        .sheet(isPresented: $isShowFolderWrite){
            
            WriteFolderView(bucketViewModel: bucketViewModel, isShowFolderWrite: $isShowFolderWrite)
                .presentationDetents([.large, .fraction(0.9)])
                    
            }
    }
     
    }

struct emptyFolderView: View {
    var body: some View {
        Text("空だよ")
    }
}

