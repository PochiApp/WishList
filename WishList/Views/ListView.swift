//
//  ListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/08.
//

import SwiftUI
import AudioToolbox
import CoreData


struct ListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var wishListViewModel : WishListViewModel
    
    let UISFGenerator = UISelectionFeedbackGenerator()
    
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
    
    @Binding var isShowPassInputPage: Bool
    @State var isShowListAdd = false
    @State var sortCheck = false
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
                listModels.nsPredicate = NSPredicate(format: "folderDate == %@", selectedFolder.writeDate! as CVarArg)

            }
        }
        
    
    
    init(wishListViewModel: WishListViewModel, selectedFolder: FolderModel, isShowPassInputPage: Binding<Bool>){
        self.wishListViewModel = wishListViewModel
        self.selectedFolder = selectedFolder
        self._isShowPassInputPage = isShowPassInputPage

        
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
        if selectedFolder.lockIsActive && isShowPassInputPage {
            PassView(wishListViewModel: wishListViewModel, selectedFolder: selectedFolder, isShowPassInputPage: $isShowPassInputPage)
        } else {
            NavigationStack {
                ZStack {

                        if listModels.isEmpty {
                            if sortCheck {
                                sortEmptyView
                            } else {
                                emptyListView
                                
                            }
                        }
                            listArea
                                .scrollContentBackground(.hidden)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(Color("\(selectedFolder.unwrappedBackColor)"), for: .navigationBar)
                                .toolbarBackground(.visible, for: .navigationBar)
                                .toolbar {
                                    ToolbarItem(placement: .topBarLeading) {
                                        backButton
                                    }
                                    
                                    ToolbarItem(placement: .principal) {
                                        navigationArea
                                    }
                                    
                                }
                                
                        
                    VStack {
                        Spacer()
                            HStack {
                                Spacer()
                                
                                sortFloatingButton
                                
                                plusFloatingButton
                        }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 25, trailing: 25))
                        
                        }
                        

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
                        UISFGenerator.selectionChanged()
                        
                        do {
                            try context.save()
                        }
                        catch {
                            print("達成チェックつけられません")
                        }
                        
                    }, label: {
                        Image(systemName: list.achievement ? "checkmark.square" : "square")
                            .font(.system(size: 30))
                    })
                    .buttonStyle(.plain)
                    .frame(alignment: .leading)
                    
                    listButtonView(list: list, selectedFolder: selectedFolder, wishListViewModel: wishListViewModel)
                            
                    }
                

            }
            .onMove(perform: moveList)
            .onDelete(perform: deleteList)
            
            Spacer().frame(height: 60)
                .listRowSeparator(.hidden)
        }
        .frame(alignment: .leading)
        .listStyle(.inset)
    }
    
    private var navigationArea : some View {
        
        
        VStack{
            Text("\(selectedFolder.unwrappedTitle)")
                    .fontWeight(.light)
            HStack{
                Text(selectedFolder.notDaySetting ? "" : "\(wishListViewModel.formattedDateString(date: selectedFolder.unwrappedStartDate)) ~ \(wishListViewModel.formattedDateString(date: selectedFolder.unwrappedFinishDate))")
                    .font(.caption)
                    .padding(.trailing)
            }
            
        }
        
    }
    
    private var backButton : some View {
        NavigationLink(destination: FolderView(wishListViewModel: wishListViewModel)) {
            Image(systemName: "arrowshape.turn.up.backward")
                .foregroundColor(Color("originalBlack"))
                .navigationBarBackButtonHidden(true)
        }
    }
    
    
    private var sortFloatingButton: some View {
        Menu{
            Menu("カテゴリー別") {
                ForEach(categorys, id: \.self) { selectCategory in
                    Button(action: {
                        categoryName = selectCategory.unwrappedCategoryName
                        listSort(sort: .categorySort)
                    }, label: {
                        Text("\(selectCategory.unwrappedCategoryName)")
                    })
                    
                }
            }
            
            Menu("達成別") {
                
                Button("未達成",
                       action: {
                    sortCheck = true
                    achievementCheck = false
                    listSort(sort: .achievementSort)})
                
                Button("達成",
                       action: {
                    sortCheck = true
                    achievementCheck = true
                    listSort(sort: .achievementSort)})
            }
            
            Button("降順",
                   action: {
                sortCheck = true
                numberSort = false
                listSort(sort: .ascending)
                })
            
            Button("昇順",
                   action: {
                sortCheck = true
                numberSort = true
                listSort(sort: .ascending)})
            
            Button("全表示",
                   action: {
                sortCheck = false
                numberSort = true
                listSort(sort: .all)})
           
        }
                label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(Color("originalBlack"))
                        .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                        .font(.system(size: 40))
                }
        
    }
                       
    
    private var plusFloatingButton: some View {
        Button(action: {
            sortCheck = false
            numberSort = true
            listSort(sort: .all)
            
            isShowListAdd = true
            wishListViewModel.folderDate = selectedFolder.writeDate ?? Date()
            wishListViewModel.listNumber = listModels.count + 1
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color("originalBlack"))
                .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                .font(.system(size: 40))
                .padding()
        })
        .sheet(isPresented: $isShowListAdd){
            
            AddListView(wishListViewModel: wishListViewModel ,isShowListAdd: $isShowListAdd, listColor: selectedFolder.unwrappedBackColor)
                .presentationDetents([.large, .fraction(0.9)])
            
        }
    }
    
    private func deleteList (offSets: IndexSet) {
        if sortCheck { return }
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
        if sortCheck { return }
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
    
    private var emptyListView: some View {
        
            VStack(alignment: .center) {
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 100))
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.bottom)
                
                Text("右下＋ボタンから、リストを作成してみましょう")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
    }
    
    private var sortEmptyView: some View {
        VStack(alignment: .center) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 100))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.bottom)
            
            Text("絞り込みした結果、リストがありません")
                .font(.caption)
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }
}
struct listButtonView: View {
    
    @State var isShowListAdd = false
    @ObservedObject var list: ListModel
    let selectedFolder: FolderModel
    @ObservedObject var wishListViewModel: WishListViewModel
    
    
    var body: some View {
        Button(action: {
            isShowListAdd = true
            wishListViewModel.editList(upList: list)
        }, label: {
            HStack {
                Text("\(list.listNumber)"+".")
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)))
                    .padding(.trailing,5)
                VStack {
                        Text("\(list.unwrappedText)")
                            .font(.headline)
                            .background(list.achievement ? Color("\(selectedFolder.unwrappedBackColor)").opacity(0.5) : Color.clear)
                            .frame(maxWidth:.infinity, alignment: .leading)
                            .padding(.bottom, 5)
                    
                    if !list.unwrappedMiniMemo.isEmpty {
                        HStack {
                            Image(systemName: "bubble.right")
                                .font(.caption2)
                            
                            Text("\(list.unwrappedMiniMemo)")
                                .font(.caption2)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                      
                    }

                }
                
                
                Spacer()
                VStack{
                    HStack{
                        if (!list.unwrappedImage1.isEmpty) {
                   
                            if let uiImage1 = UIImage(data: list.unwrappedImage1) {
                                    Image(uiImage: uiImage1)
                                        .resizable()
                                        .frame(width: 30, height:30)
                                        .clipShape(Circle())
                                }
                        }
                        
                        if (!list.unwrappedImage2.isEmpty) {
                       
                            if let uiImage2 = UIImage(data: list.unwrappedImage2) {
                                    Image(uiImage: uiImage2)
                                        .resizable()
                                        .frame(width: 30, height:30)
                                        .clipShape(Circle())
                                }
                        }
                    }
                    
            
                    Text("\(list.unwrappedCategory)")
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 70, height: 30)
                        .font(.caption)
                }
        
            
            }
            .foregroundColor(Color("originalBlack"))
        })
        .sheet(isPresented: $isShowListAdd) {
            AddListView(wishListViewModel : wishListViewModel, isShowListAdd: $isShowListAdd, listColor:selectedFolder.unwrappedBackColor)
                .presentationDetents([.large])
        }
    }
}
