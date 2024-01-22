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
    @Environment(\.editMode) var editMode
    
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var selectedFolder : FolderModel
    @FetchRequest private var listModels: FetchedResults<ListModel>
    @State var isShowListAdd = false
    
    init(bucketViewModel: BucketViewModel, selectedFolder: FolderModel){
        self.bucketViewModel = bucketViewModel
        _selectedFolder = State(initialValue: selectedFolder)

        _listModels = FetchRequest<ListModel>(entity: ListModel.entity(),
                                              sortDescriptors: [NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)],
                                              predicate: nil,
                                              animation: .default)
        
    }
    
    var body: some View {
        VStack{
            ZStack(alignment: .bottomTrailing){
                NavigationStack {
                    listArea
                        .scrollContentBackground(.hidden)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(bucketViewModel.colorList[bucketViewModel.backColor], for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                if editMode?.wrappedValue == .active {
                                    Button("完了", action: {editMode?.wrappedValue = .inactive})
                                    }
                            }
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
            ForEach(Array(listModels.enumerated()), id: \.element){ index, listmodel in
                HStack(spacing: 10){
                    
                    Button(action: {
                        listmodel.achievement.toggle()
                    }, label: {
                        Image(systemName: listmodel.achievement ? "checkmark.square" : "square")
                    })
                    .buttonStyle(.plain)
                    
                    Text("\(index + 1)"+".")
                        .padding(.trailing,20)
                    Text("\(listmodel.text!)")
                        .listRowSeparatorTint(.blue, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    
                    Spacer()
                    
                    Text("\(listmodel.category!)")
                        .font(.caption)
                    
                }
                
            }
            .onMove(perform: moveList)
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
        Menu{
            Button("編集", action: {editMode?.wrappedValue = .active})
        }label: {
            Image(systemName: "list.bullet.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
        }
    
    }
    
    private var plusFloatingButton: some View {
        Button(action: {
            isShowListAdd.toggle()
            bucketViewModel.folderDate = selectedFolder.writeDate ?? Date()
            bucketViewModel.listNumber = listModels.count + 1
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
        })
        .sheet(isPresented: $isShowListAdd){
            
            AddListView(bucketViewModel: bucketViewModel ,isShowListAdd: $isShowListAdd)
                .presentationDetents([.large])
            
        }
    }
    
    private func deleteList (offSets: IndexSet) {
        offSets.map { listModels[$0] }.forEach(context.delete)
    }
    
    private func moveList (offSets: IndexSet, destination: Int) {
        withAnimation {
            var revisedLists: [ListModel] = listModels.map{ $0 }
            revisedLists.move(fromOffsets: offSets, toOffset: destination)
            
            for reverseIndex in stride(from: revisedLists.count - 1, through: 0, by: -1){
                revisedLists[reverseIndex].listNumber = Int16(reverseIndex)
            }
            do {
                try context.save()
            }
            catch {
                print("移動失敗")
            }
        }
    }
    
}
