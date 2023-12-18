//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData

struct FolderView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: FolderModel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \FolderModel.title, ascending: true)],
            animation: .default)
        private var fm: FetchedResults<FolderModel>
    
    @State var isShowListView = false
    @State var isShowFolderAdd : Bool = false
    var folders: [FolderModels] = [
        FolderModels(title: "2023年の自分磨きやりたいこと100", startDate: "2023/01/01", finishDate: "2023/12/31", backColor: Color.red),
        FolderModels(title: "自分を変える1年", startDate: "2023/01/01", finishDate: "2023/12/31", backColor: Color.blue),
        FolderModels(title: "充実した2023年へ", startDate: "2023/01/01", finishDate: "2023/12/31",backColor: Color.yellow)
    ]
    
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
                }
             }
        }

#Preview {
    FolderView()
}

extension FolderView {
    
    
    private var folderArea: some View {
        ScrollView{
            ForEach(folders){ folder in
                Button(action: {
                    isShowListView.toggle()
                }, label: {
                    Rectangle()
                        .fill(folder.backColor)
                        .frame(width: 300, height: 150)
                        .overlay(
                            VStack(alignment: .center){
                                Text("\(folder.startDate) ~ \(folder.finishDate)")
                                    .font(.system(size: 16))
                                    .padding(.top)
                                Text("\(folder.title)")
                                    .lineLimit(2)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.top)
                                Text("達成率：20/100")
                                    .padding(.top)
                                    .font(.system(size: 15))
                            }
                                .foregroundColor(.black)
                            , alignment: .top
                        )
                        
                })
                .navigationDestination(isPresented: $isShowListView, destination: {
                    ListView()
                })
            }
            
            
            
        }
    }
    
    private var floatingButton: some View {
        Button(action: {
            isShowFolderAdd.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
        })
        .sheet(isPresented: $isShowFolderAdd){
            
            AddFolderView(isShowFolderAdd: $isShowFolderAdd)
                .presentationDetents([.large, .fraction(0.7)])
                    
            }
    }
    
    private var bottomArea: some View {
        HStack(spacing:90) {
            
            Image(systemName: "folder")
                .font(.title2)
            
            Image(systemName: "gearshape")
                .font(.title2)
            
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
        }
        
    }
    
}
