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
    
    @ObservedObject var bucketViewModel : BucketViewModel
    private let selectedFolder : FolderModel
    @FetchRequest(
                entity: ListModel.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)], 
                animation:.default)
    private var listModels: FetchedResults<ListModel>
    
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    
    @State var isShowListAdd = false
    @State var numberSort = true
    @State var achievementCheck = false
    @State var categoryName = ""
    
    enum Sort {
        case ascending
        case achievementSort
        case categorySort
        case all
    }
        
    private func listSort(sort: Sort){
            
            let listNumberSorted: NSSortDescriptor = NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: numberSort)
            
            let achievementPredicate: NSPredicate = NSPredicate(format: "achievement == %@ and folderDate == %@", NSNumber(value:achievementCheck),selectedFolder.writeDate! as CVarArg)
            
            let categoryPredicate: NSPredicate = NSPredicate(format: "category == %@ and folderDate == %@", categoryName, selectedFolder.writeDate! as CVarArg)
                                                             
            switch sort{
            case .ascending:
                listModels.nsSortDescriptors = [listNumberSorted]

            case .achievementSort:
                listModels.nsSortDescriptors = [listNumberSorted]
                listModels.nsPredicate = achievementPredicate
                
            case .categorySort:
                listModels.nsSortDescriptors = [listNumberSorted]
                listModels.nsPredicate = categoryPredicate
            
            case .all:
                listModels.nsSortDescriptors = [listNumberSorted]
                listModels.nsPredicate = NSPredicate(format: "folderDate == %@", selectedFolder.writeDate! as CVarArg)
               
            }
        }
        
    
    
    init(bucketViewModel: BucketViewModel, selectedFolder: FolderModel){
        self.bucketViewModel = bucketViewModel
        self.selectedFolder = selectedFolder
        
        guard let selectedFolderDate = selectedFolder.writeDate else{
            return
        }
        let listPredicate = NSPredicate(format: "folderDate == %@", selectedFolderDate as CVarArg)
        
        let fetchRequest: NSFetchRequest<ListModel> = ListModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)]
        fetchRequest.predicate = listPredicate
        _listModels = FetchRequest(fetchRequest: fetchRequest)
    }
    
    
    
    var body: some View {
        VStack{
            ZStack(alignment: .bottomTrailing){
                NavigationStack {
                    listArea
                        .scrollContentBackground(.hidden)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(bucketViewModel.colorList[Int(selectedFolder.backColor)], for: .navigationBar)
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
            ForEach(listModels){ list in
                HStack(spacing: 10){
                    
                    Button(action: {
                        list.achievement.toggle()
                        do {
                            try context.save()
                        }
                        catch {
                            print("達成チェックつけられません")
                        }
                        
                    }, label: {
                        Image(systemName: list.achievement ? "checkmark.square" : "square")
                    })
                    .buttonStyle(.plain)
                    
                    Text("\(list.listNumber)"+".")
                        .padding(.trailing,20)
                    Text("\(list.text!)")
                        .listRowSeparatorTint(.blue, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    
                    Spacer()
                    
                    Text("\(list.category!)")
                        .font(.caption)
                    
                }
                .onTapGesture(perform: {
                    isShowListAdd.toggle()
                    bucketViewModel.editList(upList: list)
                })
                .sheet(isPresented: $isShowListAdd) {
                    
                    AddListView(bucketViewModel : bucketViewModel, isShowListAdd: $isShowListAdd, listColor:bucketViewModel.colorList[Int(selectedFolder.backColor)])
                        .presentationDetents([.large])
                }
            }
            .onMove(perform: moveList)
            .onDelete(perform: deleteList)
            
            Spacer()
        }
        
        
    }
    
    
    
    private var navigationArea : some View {
        
        
        VStack{
            Text("\(selectedFolder.title!)")
                .font(.headline)
            HStack{
                Text(selectedFolder.notDaySetting ? "" : "\(bucketViewModel.formattedDateString(date: selectedFolder.startDate ?? Date())) ~ \(bucketViewModel.formattedDateString(date: selectedFolder.finishDate ?? Date()))")
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
            Menu("カテゴリー別") {
                ForEach(categorys, id: \.self) { selectCategory in
                    Button(action: {
                        categoryName = selectCategory.categoryName ?? ""
                        listSort(sort: .categorySort)
                    }, label: {
                        Text("\(selectCategory.categoryName!)")
                    })
                    
                }
            }
            
            Menu("達成別") {
                
                Button("未達成",
                       action: {
                    achievementCheck = false
                    listSort(sort: .achievementSort)})
                
                Button("達成",
                       action: {
                    achievementCheck = true
                    listSort(sort: .achievementSort)})
            }
            
            Button("降順",
                   action: {
                numberSort = false
                listSort(sort: .ascending)
                })
            
            Button("昇順",
                   action: {
                numberSort = true
                listSort(sort: .ascending)})
            
            Button("全表示",
                   action: {
                numberSort = true
                listSort(sort: .all)})
           
        }
                label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
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
            
            AddListView(bucketViewModel: bucketViewModel ,isShowListAdd: $isShowListAdd, listColor: bucketViewModel.colorList[Int(selectedFolder.backColor)])
                .presentationDetents([.large])
            
        }
    }
    
    private func deleteList (offSets: IndexSet) {
        offSets.map { listModels[$0] }.forEach(context.delete)
        
        
        do {
            try context.save()
            
            updateListNumber()
        }
        catch {
            print("削除失敗")
        }
        
        
    }
        
    private func updateListNumber(){
        let sortedListModels = Array(listModels)
        
        for reverseIndex in stride(from: sortedListModels.count - 1, through: 0, by: -1){
            sortedListModels[reverseIndex].listNumber = Int16(reverseIndex + 1)
            
        }
        do {
            try context.save()
            
        }
        catch {
            print("listNumber変更失敗")
        }
    }
    
    
    private func moveList (offSets: IndexSet, destination: Int) {
        withAnimation {
            var revisedLists = Array(listModels)
            revisedLists.move(fromOffsets: offSets, toOffset: destination)
            
            if (numberSort == true) {
                for reverseIndex in stride(from: revisedLists.count - 1, through: 0, by: -1){
                    revisedLists[reverseIndex].listNumber = Int16(reverseIndex + 1)
                }} else {
                    revisedLists.reverse()
                    for reverseIndex in stride(from: revisedLists.count - 1, through: 0, by: -1){
                        revisedLists[reverseIndex].listNumber = Int16(reverseIndex + 1)
                }
            
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
