//
//  ListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/08.
//

import SwiftUI
import CoreData

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)],
//            predicate: NSPredicate(format: "ListModel.folderDate == selectedFolder.writeDate"),
            animation: .default)
        private var listModels: FetchedResults<ListModel>
    @State var isShowListAdd = false
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var selectedFolder : FolderModel
    
    var body: some View {
        VStack{
            ZStack(alignment: .bottomTrailing){
                NavigationStack {
                    listArea
                        .scrollContentBackground(.hidden)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(.gray, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                backButton
                            }
                            ToolbarItem(placement: .principal) {
                                navigationArea
                            }
                            
                            ToolbarItemGroup(placement: .bottomBar){
                                bottomArea
                            }
                        }
                    }
                    
                HStack{
                    
                    sortFloatingButton
                    
                    plusFloatingButton
                    
                    }
  
                }
                
                
            }
  }
}

extension ListView {
    
    private var listArea : some View {
            List {
                ForEach(listModels){ listmodel in
                    HStack(spacing: 10){
                       
                        Button(action: {
                            listmodel.achievement.toggle()
                        }, label: {
                            Image(systemName: listmodel.achievement ? "checkmark.square" : "square")
                        })
                        .buttonStyle(.plain)
                        
                        Text("\(listmodel.listNumber)"+".")
                            .padding(.trailing,20)
                        Text("\(listmodel.text!)")
                            .listRowSeparatorTint(.blue, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        
                        Spacer()
                        
                        Text("\(listmodel.category!)")
                            .font(.caption)
                        
                    }
                   
                    }
                        .onDelete(perform: deleteList)
        
        }
        
        }
    
    private var navigationArea : some View {
        
                
            VStack{
                Text("\(selectedFolder.title!)")
                    .font(.headline)
                HStack{
                    Text("\(bucketViewModel.formattedDateString(date: selectedFolder.startDate ?? Date())) ~ \(bucketViewModel.formattedDateString(date: selectedFolder.finishDate ?? Date()))")
                        .font(.subheadline)
                        .padding(.trailing)
                }
            
        }
        
    }
    
    private var backButton : some View {
        NavigationLink(destination: FolderView()) {
            Image(systemName: "arrowshape.turn.up.backward")
                .foregroundColor(.black)
                .navigationBarBackButtonHidden(true)
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
    
    private var sortFloatingButton: some View {
        Image(systemName: "list.bullet.circle.fill")
            .foregroundColor(.black)
            .font(.largeTitle)
    }
    
    private var plusFloatingButton: some View {
        Button(action: {
            isShowListAdd.toggle()
            selectedFolder.writeDate = bucketViewModel.folderDate
            bucketViewModel.listNumber = listModels.count + 1
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
        })
        .sheet(isPresented: $isShowListAdd){
            
            AddListView(bucketViewModel: bucketViewModel ,isShowListAdd: $isShowListAdd)
                .presentationDetents([.medium, .fraction(0.5)])
                    
            }
    }
    
    private func deleteList (offSets: IndexSet) {
        offSets.map { listModels[$0] }.forEach(context.delete)
    }
    
    
}

