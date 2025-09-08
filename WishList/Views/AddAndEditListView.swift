//
//  AddListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI
import PhotosUI

struct AddAndEditListView: View {
    
    @Environment(\.managedObjectContext)private var context
    @Environment(\.dismiss) var dismiss
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    
    @StateObject var listViewModel: ListViewModel
    @Binding var isShowAddAndEditListView: Bool
    @State var listColor: String
    @State var selectedPhoto: [PhotosPickerItem] = []
    @FocusState var textFieldIsActive: Field?
    let mode: Mode
    
    //編集モードか新規モードかでViewModelでオーバーロードしたinitを切り替え
    enum Mode {
        case add(listNumber: Int, folderDate: Date)
        case edit(updateList: ListModel)
        
        var writeListLabel: String {
            switch self {
            case .add: return "作成"
            case .edit: return "変更"
            }
        }
        
        var navigationTitle: String {
            switch self {
            case .add: return "リスト作成"
            case .edit: return "リスト編集"
            }
        }
    }
    
    //TextFieldのフォーカスを、textの時とminiMemoの時で分けている
    enum Field: Hashable {
        case text
        case miniMemo
    }
    
    init(isShowAddAndEditListView: Binding<Bool>, listColor: String, mode: Mode) {
        self._isShowAddAndEditListView = isShowAddAndEditListView
        self.mode = mode
        self.listColor = listColor
        
        switch mode {
        case .add(let listNumber, let folderDate):
            _listViewModel = StateObject(wrappedValue: ListViewModel(listNumber: listNumber, folderDate: folderDate))
        case .edit(let updateList):
            _listViewModel = StateObject(wrappedValue: ListViewModel(update: updateList))
        }
    }
    
    var body: some View {
        VStack {
            NavigationStack{
                Form {
                    Section(header: Text("やりたいこと/欲しいもの など")) {
                        wishListTextField
                    }
                    
                    Section(header: Text("カテゴリー").foregroundColor(Color("originalBlack"))) {
                        categoryPicker
                        
                        //カテゴリー追加画面への遷移ボタン
                        NavigationLink(
                            destination: CategoryView()
                        ){
                            Text("カテゴリー追加へ")
                                .font(.subheadline)
                                .foregroundColor(Color("originalBlack"))
                        }
                    }
                    
                    Section(header: Text("画像")) {
                        
                        PhotosPicker(selection: $selectedPhoto, maxSelectionCount: 2, selectionBehavior: .ordered, matching: .images) {
                            if listViewModel.images.isEmpty {
                                //ViewModelのimagesが空だったときは、noimage画像の表示
                                Image("noimage")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                HStack {
                                    ForEach(listViewModel.images, id:\.self) { image in
                                        if let image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }
                                }
                                //選択した画像削除ボタン
                                selectedPhotosDeleteButton
                            }
                        }
                        //PhotosPickerで選択した画像の処理
                        .onChange(of: selectedPhoto){ newSelectedPhoto in
                            //ViewModelのdatas初期化処理
                            if !listViewModel.datas.isEmpty {
                                listViewModel.datas.removeAll()
                            }
                            
                            Task {
                                //PhotosPickerで選択したImageをData型に変換
                                await listViewModel.convertDataimages(photos: newSelectedPhoto)
                                
                                //Imageの数に応じた分岐処理
                                switch listViewModel.datas.count {
                                    //Coredataには、UIImage型ではなくData型で保存
                                case 1 :
                                    DispatchQueue.main.async {
                                        listViewModel.image1 = listViewModel.datas[0]
                                        listViewModel.image2 = Data.init()
                                        print("case1")
                                    }
                                case 2 :
                                    DispatchQueue.main.async {
                                        listViewModel.image1 = listViewModel.datas[0]
                                        listViewModel.image2 = listViewModel.datas[1]
                                        print("case2")
                                    }
                                default :
                                    DispatchQueue.main.async {
                                        listViewModel.image1 = Data.init()
                                        listViewModel.image2 = Data.init()
                                        print("default")
                                    }
                                    return
                                }
                                
                                //Data型→UIImage型への変換
                                await listViewModel.convertUiimages()
                            }
                        }
                        .onAppear() {
                            Task {
                                //Listに保存しているData型のImageをUIImage型に変換して表示
                                await listViewModel.convertUiimages()
                            }
                            if !categorys.map { $0.unwrappedCategoryName }.contains(listViewModel.category) {
                                listViewModel.category = ""
                            }
                        }
                    }
                    
                    Section(header: Text("一言メモ")) {
                        wishListMiniMemoTextField
                    }
                    
                    //Listの編集時は、達成チェックボックスの表示
                    if listViewModel.updateList != nil {
                        Section(header: Text("達成チェック")) {
                            achievementCheckBox
                        }
                    }
                }
                .background(Color.gray.opacity(0.1))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color("\(listColor)"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        navigationTitle
                    }
                    ToolbarItem(placement: .topBarLeading){
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .topBarTrailing){
                        writeListButton
                    }
                }
            }
        }
    }
}

//MARK: - extension
extension AddAndEditListView {
    private var wishListTextField: some View {
        TextField("やりたいこと/欲しいもの など", text: $listViewModel.text)
            .focused($textFieldIsActive, equals: .text)
            .onTapGesture {
                textFieldIsActive = nil
            }
    }
    
    private var categoryPicker: some View {
        Picker("カテゴリー", selection: $listViewModel.category) {
            Text("未選択").tag("")
            ForEach(categorys, id: \.self) { category in
                Text("\(category.unwrappedCategoryName)")
                    .tag(category.unwrappedCategoryName)
            }
        }
    }
    
    private var selectedPhotosDeleteButton: some View {
        Button(action: {
            selectedPhoto = []
            listViewModel.resetImages()
        }) {
            Text("画像削除")
                .foregroundColor(.red)
        }
    }
    
    private var wishListMiniMemoTextField: some View {
        TextField("一言メモ", text: $listViewModel.miniMemo)
            .focused($textFieldIsActive, equals: .miniMemo)
            .onTapGesture {
                textFieldIsActive = nil
            }
    }
    
    private var achievementCheckBox: some View {
        Button(action: {
            listViewModel.achievement.toggle()
            do {
                try context.save()
            }
            catch {
                print("達成チェックつけられません")
            }
            
        }, label: {
            Image(systemName: listViewModel.achievement ? "checkmark.square" : "square")
                .foregroundColor(Color("originalBlack"))
        })
        .buttonStyle(.plain)
    }
    
    private var writeListButton: some View {
        Button(action: {
            
            listViewModel.writeList(context: context)
            
            dismiss()
            
            listViewModel.resetList()
            
        }, label: {
            Text(mode.writeListLabel)
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        })
    }
    
    //モーダル上部のタイトル名
    private var navigationTitle: some View {
        Text(mode.navigationTitle)
            .font(.title3)
            .foregroundColor(Color("originalBlack"))
    }
    
    
    private var cancelButton: some View {
        Button(action: {
            dismiss()
            listViewModel.resetList()
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title2)
                .foregroundColor(Color("originalBlack"))
        })
    }
}

