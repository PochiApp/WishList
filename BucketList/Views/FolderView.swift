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
    @StateObject var bucketViewModel = BucketViewModel()
    @State var isShowListView = false
    @State var isShowFolderWrite: Bool = false
    
    
    var body: some View {
        VStack {
            NavigationStack{
                ZStack(alignment: .bottomTrailing) {
                    
                    folderArea
                    
                    
                    floatingButton
                        
                        }
                .toolbar{
                    ToolbarItemGroup(placement: .bottomBar) {
                        
                        bottomArea
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

#Preview {
    FolderView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

extension FolderView {
    
    
    private var folderArea: some View {
        ScrollView{
            ForEach(fm){foldermodel in
                NavigationLink(destination: ListView(bucketViewModel: bucketViewModel, selectedFolder: foldermodel)){
                    Rectangle()
                        .fill(bucketViewModel.colorList[Int(foldermodel.backColor)])
                        .frame(width: 300, height: 150)
                        .overlay(
                            VStack(alignment: .center){
                                Text(foldermodel.notDaySetting ? "" : "\(bucketViewModel.formattedDateString(date: foldermodel.startDate ?? Date())) ~ \(bucketViewModel.formattedDateString(date: foldermodel.finishDate ?? Date()))")
                                    .font(.system(size: 16))
                                    .padding(.top)
                                Text("\(foldermodel.title!)")
                                    .lineLimit(2)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.top)
                                Text("達成率：20/\(foldermodel.lists!.count)")
                                    .padding(.top)
                                    .font(.system(size: 15))
                                
                            }
                                .foregroundColor(.black)
                            , alignment: .top
                        )
       
            
        }
                .contextMenu(ContextMenu(menuItems: {
                    Button(action: {
                        context.delete(foldermodel)
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
            }
        }
    }
    
    private var floatingButton: some View {
        Button(action: {
            isShowFolderWrite.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
        })
        .sheet(isPresented: $isShowFolderWrite){
            
            WriteFolderView(bucketViewModel: bucketViewModel, isShowFolderWrite: $isShowFolderWrite)
                .presentationDetents([.large, .fraction(0.9)])
                    
            }
    }
    
    private var bottomArea: some View {
        HStack(spacing:90) {
            NavigationLink(destination: FolderView()) {
                Image(systemName: "folder")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Image(systemName: "gearshape")
                .font(.title2)
            
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
        }
        }
    

        
    }

    

