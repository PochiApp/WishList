//
//  ListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/08.
//

import AudioToolbox
import CoreData
import SwiftUI

struct ListView: View {

    @Environment(\.managedObjectContext) private var context

    let UISFGenerator = UISelectionFeedbackGenerator()

    //Listのフェッチ
    private let selectedFolder: FolderModel
    @FetchRequest(
        entity: ListModel.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)
        ],
        animation: .default
    )
    private var listModels: FetchedResults<ListModel>

    //Categoryのフェッチ
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CategoryEntity.categoryAddDate,
                ascending: true
            )
        ],
        animation: .default
    )
    private var categorys: FetchedResults<CategoryEntity>

    @Binding var isInsertPassViewBeforeListView: Bool
    @State var isShowAddAndEditListView = false
    @State var sortCheck = false
    @State var numberSort = true
    @State var achievementCheck = false
    @State var categoryName = ""

    //絞り込みの種類
    enum Sort {
        case ascending
        case achievementSort
        case categorySort
        case all
    }

    private func listSort(sort: Sort) {
        //リストのindex昇順
        let listNumberSorted: NSSortDescriptor = NSSortDescriptor(
            keyPath: \ListModel.listNumber,
            ascending: numberSort
        )

        //達成済の絞り込み (達成または未達成の一致かつ選択したFolderの作成日時と一致するリストの表示)
        let achievementPredicate: NSPredicate = NSPredicate(
            format: "achievement == %@ and folderDate == %@",
            NSNumber(value: achievementCheck),
            selectedFolder.writeDate! as CVarArg
        )

        //カテゴリーの絞り込み (カテゴリー名一致かつ選択したFolderの作成日時と一致するリストの表示)
        let categoryPredicate: NSPredicate = NSPredicate(
            format: "category == %@ and folderDate == %@",
            categoryName,
            selectedFolder.writeDate! as CVarArg
        )

        //絞り込みの種類による分岐で処理
        switch sort {
        case .ascending:
            listModels.nsSortDescriptors = [listNumberSorted]

        case .achievementSort:
            listModels.nsSortDescriptors = [listNumberSorted]
            listModels.nsPredicate = achievementPredicate

        case .categorySort:
            listModels.nsSortDescriptors = [listNumberSorted]
            listModels.nsPredicate = categoryPredicate

        //全表示
        case .all:
            listModels.nsPredicate = NSPredicate(
                format: "folderDate == %@",
                selectedFolder.writeDate! as CVarArg
            )

        }
    }

    init(
        selectedFolder: FolderModel,
        isInsertPassViewBeforeListView: Binding<Bool>
    ) {
        self.selectedFolder = selectedFolder
        self._isInsertPassViewBeforeListView = isInsertPassViewBeforeListView

        //ListのselectedFolderdateとselectedFolderのwriteDateが一致しない場合は、returnで処理をしない
        guard let selectedFolderDate = selectedFolder.writeDate else {
            return
        }

        //selectedFolderDateとfolderDateが一致するListの絞り込み表示
        let listPredicate = NSPredicate(
            format: "folderDate == %@",
            selectedFolderDate as CVarArg
        )

        let fetchRequest: NSFetchRequest<ListModel> = ListModel.fetchRequest()
        //Listのindex昇順に並べるよう指定
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ListModel.listNumber, ascending: true)
        ]
        fetchRequest.predicate = listPredicate
        //これら条件でフェッチ
        _listModels = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        if selectedFolder.lockIsActive && isInsertPassViewBeforeListView {
            PassView(
                selectedFolder: selectedFolder,
                isInsertPassViewBeforeListView: $isInsertPassViewBeforeListView
            )
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
                        .toolbarBackground(
                            Color("\(selectedFolder.unwrappedBackColor)"),
                            for: .navigationBar
                        )
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
                        .padding(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 25,
                                trailing: 25
                            )
                        )
                    }
                }
            }
        }
    }
}

extension ListView {

    private var listArea: some View {
        List {
            ForEach(listModels) { list in
                HStack(spacing: 10) {
                    //達成チェクボタンの表示
                    Button(
                        action: {
                            list.achievement.toggle()
                            UISFGenerator.selectionChanged()

                            do {
                                try context.save()
                            } catch {
                                print("達成チェックつけられません")
                            }
                        },
                        label: {
                            Image(
                                systemName: list.achievement
                                    ? "checkmark.square" : "square"
                            )
                            .font(.system(size: 30))
                        }
                    )
                    .buttonStyle(.plain)
                    .frame(alignment: .leading)

                    listButtonView(
                        list: list,
                        selectedFolder: selectedFolder,
                        context: context
                    )
                }
            }
            .onMove(perform: moveListAndUpdateListNumber)  //リストの長押しスワイプ並び替え
            .onDelete(perform: deleteList)  //横スワイプでDeleteボタンの表示/削除

            //リスト一番下が、floatingButtonが邪魔して横スワイプ削除できないので空白を入れている
            Spacer().frame(height: 60)
                .listRowSeparator(.hidden)
        }
        .frame(alignment: .leading)
        .listStyle(.inset)
    }

    private var navigationArea: some View {
        VStack {
            Text("\(selectedFolder.unwrappedTitle)")
                .fontWeight(.light)
            HStack {
                Text(
                    selectedFolder.notDaySetting
                        ? ""
                        : "\(selectedFolder.unwrappedStartDate.formattedDateString()) ~ \(selectedFolder.unwrappedFinishDate.formattedDateString())"
                )
                .font(.caption)
                .padding(.trailing)
            }
        }
    }

    private var backButton: some View {
        NavigationLink(destination: FolderView()) {
            Image(systemName: "arrowshape.turn.up.backward")
                .foregroundColor(Color("originalBlack"))
                .navigationBarBackButtonHidden(true)
        }
    }

    private var sortFloatingButton: some View {
        Menu {
            Menu("カテゴリー別") {
                ForEach(categorys, id: \.self) { selectCategory in
                    Button(
                        action: {
                            categoryName = selectCategory.unwrappedCategoryName
                            listSort(sort: .categorySort)
                        },
                        label: {
                            Text("\(selectCategory.unwrappedCategoryName)")
                        }
                    )
                }
            }

            Menu("達成別") {
                Button(
                    "未達成",
                    action: {
                        sortCheck = true
                        achievementCheck = false
                        listSort(sort: .achievementSort)
                    }
                )

                Button(
                    "達成",
                    action: {
                        sortCheck = true
                        achievementCheck = true
                        listSort(sort: .achievementSort)
                    }
                )
            }

            Button(
                "降順",
                action: {
                    sortCheck = true
                    numberSort = false
                    listSort(sort: .ascending)
                }
            )

            Button(
                "昇順",
                action: {
                    sortCheck = true
                    numberSort = true
                    listSort(sort: .ascending)
                }
            )

            Button(
                "全表示",
                action: {
                    sortCheck = false
                    numberSort = true
                    listSort(sort: .all)
                }
            )

        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(Color("originalBlack"))
                .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                .font(.system(size: 40))
        }
    }

    private var plusFloatingButton: some View {
        Button(
            action: {
                sortCheck = false
                numberSort = true
                listSort(sort: .all)

                isShowAddAndEditListView = true
            },
            label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("originalBlack"))
                    .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                    .font(.system(size: 40))
                    .padding()
            }
        )
        .sheet(isPresented: $isShowAddAndEditListView) {

            AddAndEditListView(
                isShowAddAndEditListView: $isShowAddAndEditListView,
                listColor: selectedFolder.unwrappedBackColor,
                mode: .add(
                    listNumber: listModels.count + 1,
                    folderDate: selectedFolder.writeDate ?? Date()
                )
            )
            .presentationDetents([.large])
            .onDisappear {
                context.rollback()
            }
        }
    }

    private func deleteList(offSets: IndexSet) {
        if sortCheck { return }
        offSets.map { listModels[$0] }.forEach(context.delete)
        do {
            try context.save()
            updateListNumber()
        } catch {
            print("リスト削除失敗")
        }
    }

    //List削除時のindex更新メソッド
    private func updateListNumber() {
        let sortedListModels = Array(listModels)

        for reverseIndex in stride(
            from: sortedListModels.count - 1,
            through: 0,
            by: -1
        ) {
            sortedListModels[reverseIndex].listNumber = Int16(reverseIndex + 1)
        }
        do {
            try context.save()
        } catch {
            print("listNumber変更失敗")
        }
    }

    //List並び替えとindexの更新メソッド
    private func moveListAndUpdateListNumber(
        offSets: IndexSet,
        destination: Int
    ) {
        if sortCheck { return }
        withAnimation {
            var ListsArray = Array(listModels)
            ListsArray.move(fromOffsets: offSets, toOffset: destination)

            //ソート機能で昇順と降順で並び替えられている場合で、indexの変更方法を分岐
            for reverseIndex in stride(
                from: ListsArray.count - 1,
                through: 0,
                by: -1
            ) {
                ListsArray[reverseIndex].listNumber = Int16(reverseIndex + 1)
            }
            do {
                try context.save()
            } catch {
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

    //絞り込みの結果がなかった場合のView
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

//Listの達成チェックボックス以外のメイン表示部分
struct listButtonView: View {
    @State var isShowListAdd = false
    @ObservedObject var list: ListModel
    let selectedFolder: FolderModel
    let context: NSManagedObjectContext

    var body: some View {
        Button(
            action: {
                //Listクリックで編集ページの表示
                isShowListAdd = true
            },
            label: {
                HStack {
                    //Listのindex番号表示
                    Text("\(list.listNumber)" + ".")
                        .font(
                            Font(
                                UIFont.monospacedSystemFont(
                                    ofSize: 20,
                                    weight: .regular
                                )
                            )
                        )
                        .padding(.trailing, 5)

                    VStack {
                        //Listのメインテキスト部分
                        Text("\(list.unwrappedText)")
                            .font(.headline)
                            .background(
                                list.achievement
                                    ? Color(
                                        "\(selectedFolder.unwrappedBackColor)"
                                    ).opacity(0.5) : Color.clear
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)

                        //ListのminiMemoが空でなければ表示
                        if !list.unwrappedMiniMemo.isEmpty {
                            HStack {
                                Image(systemName: "bubble.right")
                                    .font(.caption2)

                                Text("\(list.unwrappedMiniMemo)")
                                    .font(.caption2)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                            }
                        }
                    }

                    Spacer()

                    VStack {
                        HStack {
                            //Image1の表示
                            if !list.unwrappedImage1.isEmpty {

                                if let uiImage1 = UIImage(
                                    data: list.unwrappedImage1
                                ) {
                                    Image(uiImage: uiImage1)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                            }

                            //Image2の表示
                            if !list.unwrappedImage2.isEmpty {

                                if let uiImage2 = UIImage(
                                    data: list.unwrappedImage2
                                ) {
                                    Image(uiImage: uiImage2)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                            }
                        }

                        //カテゴリーの表示
                        if !list.unwrappedCategory.isEmpty {
                            Text(
                                list.unwrappedCategory.count > 10
                                    ? "\(String(list.unwrappedCategory.prefix(10)))･･･"
                                    : "\(list.unwrappedCategory)"
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 70, height: 30)
                            .font(.caption)
                        }
                    }
                }
                .foregroundColor(Color("originalBlack"))
            }
        )
        .sheet(isPresented: $isShowListAdd) {
            AddAndEditListView(
                isShowAddAndEditListView: $isShowListAdd,
                listColor: selectedFolder.unwrappedBackColor,
                mode: .edit(updateList: list)
            )
            .presentationDetents([.large])
        }
        .onDisappear {
            context.rollback()
        }
    }
}
