//
//  AddListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI
import PhotosUI

struct AddAndEditListView: View {
    
    @Environment (\.managedObjectContext)private var context
    @Environment (\.dismiss) var dismiss
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    
    @ObservedObject var wishListViewModel : WishListViewModel
    @Binding var isShowAddAndEditListView: Bool
    @State var listColor: String
    @State var selectedPhoto: [PhotosPickerItem] = []
    @FocusState var textFieldIsActive: Field?
    
    //TextFieldのフォーカスを、textの時とminiMemoの時で分けている
    enum Field: Hashable {
        case text
        case miniMemo
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
                            destination: CategoryView(wishListViewModel: wishListViewModel)
                                .onDisappear(perform: {
                                    firstCategoryGet()
                                })){
                                    Text("カテゴリー追加へ")
                                        .font(.subheadline)
                                        .foregroundColor(Color("originalBlack"))
                                }
                    }
                    
                    Section(header: Text("画像")) {
                        
                        PhotosPicker(selection: $selectedPhoto, maxSelectionCount: 2, selectionBehavior: .ordered, matching: .images) {
                            if wishListViewModel.images.isEmpty {
                                //ViewModelのimagesが空だったときは、noimage画像の表示
                                Image("noimage")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                HStack {
                                    ForEach(wishListViewModel.images, id:\.self) { image in
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
                            if !wishListViewModel.datas.isEmpty {
                                wishListViewModel.datas.removeAll()
                            }
                            
                            Task {
                                //PhotosPickerで選択したImageをData型に変換
                                await wishListViewModel.convertDataimages(photos: newSelectedPhoto)
                                
                                //Imageの数に応じた分岐処理
                                switch wishListViewModel.datas.count {
                                //Coredataには、UIImage型ではなくData型で保存
                                case 1 :
                                    DispatchQueue.main.async {
                                        wishListViewModel.image1 = wishListViewModel.datas[0]
                                        wishListViewModel.image2 = Data.init()
                                        print("case1")
                                    }
                                case 2 :
                                    DispatchQueue.main.async {
                                        wishListViewModel.image1 = wishListViewModel.datas[0]
                                        wishListViewModel.image2 = wishListViewModel.datas[1]
                                        print("case2")
                                    }
                                default :
                                    DispatchQueue.main.async {
                                        wishListViewModel.image1 = Data.init()
                                        wishListViewModel.image2 = Data.init()
                                        print("default")
                                    }
                                    return
                                }
                                
                                //Data型→UIImage型への変換
                                await wishListViewModel.convertUiimages()
                            }
                        }
                        .onAppear() {
                            
                            if wishListViewModel.updateList == nil {
                                //CategoryPickerの初期値の設定
                                firstCategoryGet()
                            }
                            Task {
                                //Listに保存しているData型のImageをUIImage型に変換して表示
                                await wishListViewModel.convertUiimages()
                            }
                        }
                    }
                    
                    Section(header: Text("一言メモ")) {
                        wishListMiniMemoTextField
                    }
                    
                    //Listの編集時は、達成チェックボックスの表示
                    if wishListViewModel.updateList !== nil {
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
        TextField("やりたいこと/欲しいもの など", text: $wishListViewModel.text)
            .focused($textFieldIsActive, equals: .text)
            .onTapGesture {
                textFieldIsActive = nil
            }
    }
    
    private var categoryPicker: some View {
        Picker("カテゴリー", selection: $wishListViewModel.category) {
            ForEach(categorys, id: \.self) { category in
                Text("\(category.unwrappedCategoryName)")
                    .tag(category.unwrappedCategoryName)
            }
        }
    }
    
    private var selectedPhotosDeleteButton: some View {
        Button(action: {
            selectedPhoto = []
            wishListViewModel.resetImages()
        }) {
            Text("画像削除")
                .foregroundColor(.red)
        }
    }
    
    private var wishListMiniMemoTextField: some View {
        TextField("一言メモ", text: $wishListViewModel.miniMemo)
            .focused($textFieldIsActive, equals: .miniMemo)
            .onTapGesture {
                textFieldIsActive = nil
            }
    }
    
    private var achievementCheckBox: some View {
        Button(action: {
            wishListViewModel.achievement.toggle()
            do {
                try context.save()
            }
            catch {
                print("達成チェックつけられません")
            }
            
        }, label: {
            Image(systemName: wishListViewModel.achievement ? "checkmark.square" : "square")
                .foregroundColor(Color("originalBlack"))
        })
        .buttonStyle(.plain)
    }
    
    private var writeListButton: some View {
        Button(action: {
            
            wishListViewModel.writeList(context: context)
            
            dismiss()
            
            wishListViewModel.resetList()
            
        }, label: {
            Text(wishListViewModel.updateList == nil ? "作成" : "変更")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        })
    }
    
    private var navigationTitle: some View {
        if wishListViewModel.updateList == nil {
            Text("リスト作成")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
            
        } else {
            Text("リスト編集")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        }
    }
    
    
    private var cancelButton: some View {
        Button(action: {
            dismiss()
            wishListViewModel.resetList()
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title2)
                .foregroundColor(Color("originalBlack"))
        })
    }
    
    private func firstCategoryGet() {
        let arrayCategory = Array(categorys)
        wishListViewModel.category = arrayCategory.first?.categoryName ?? ""
    }
}

