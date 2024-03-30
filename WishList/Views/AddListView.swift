//
//  AddListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI
import PhotosUI

struct AddListView: View {
    
    @Environment (\.managedObjectContext)private var context
    @Environment (\.dismiss) var dismiss
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    
    @ObservedObject var bucketViewModel : BucketViewModel
    @Binding var isShowListAdd: Bool
    @State var listColor: String
    @State var selectedPhoto: [PhotosPickerItem] = []
    @FocusState var textFieldIsActive: Field?
    
    enum Field: Hashable {
        case text
        case miniMemo
    }
    
    
    var body: some View {
        VStack {
            NavigationStack{
                Form {
                    Section(header: Text("やりたいこと/欲しいもの など")) {
                        bucketTextField
                    }
                    
                    Section(header: Text("カテゴリー").foregroundColor(Color("originalBlack"))) {
                        categoryPicker
                        
                        NavigationLink(
                            destination: CategoryView(bucketViewModel: bucketViewModel)
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
                            if bucketViewModel.images.isEmpty {
                                Image("noimage")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                HStack {
                                    ForEach(bucketViewModel.images, id:\.self) { image in
                                        if let image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }
                                }
                            
                                    Button(action: {
                                        selectedPhoto = []
                                        bucketViewModel.resetImages()
                                    }) {
                                        Text("画像削除")
                                            .foregroundColor(.red)
                                    }
                            }
                        }
                        .onChange(of: selectedPhoto){ newSelectedPhoto in
                            if !bucketViewModel.datas.isEmpty {
                                bucketViewModel.datas.removeAll()
                            }
                            
                            Task {
                                await bucketViewModel.convertDataimages(photos: newSelectedPhoto)
                                
                                switch bucketViewModel.datas.count {
                                case 1 :
                                    DispatchQueue.main.async {
                                        bucketViewModel.image1 = bucketViewModel.datas[0]
                                        bucketViewModel.image2 = Data.init()
                                        print("case1")
                                    }
                                case 2 :
                                    DispatchQueue.main.async {
                                        bucketViewModel.image1 = bucketViewModel.datas[0]
                                        bucketViewModel.image2 = bucketViewModel.datas[1]
                                        print("case2")
                                    }
                                default :
                                    DispatchQueue.main.async {
                                        bucketViewModel.image1 = Data.init()
                                        bucketViewModel.image2 = Data.init()
                                        print("default")
                                    }
                                    return
                                    
                                }
                                
                               await bucketViewModel.convertUiimages()
                                
                            }
                        }
                        .onAppear() {
                            if bucketViewModel.updateList == nil {
                                firstCategoryGet()
                            }
                            Task {
                                await bucketViewModel.convertUiimages()
                            }
                        }
                       
                        
                    }
                    
                    Section(header: Text("一言メモ")) {
                        bucketMiniMemoTextField
                    }
                            
                            if bucketViewModel.updateList !== nil {
                                Section(header: Text("達成チェック")) {
                                    Button(action: {
                                        bucketViewModel.achievement.toggle()
                                        do {
                                            try context.save()
                                        }
                                        catch {
                                            print("達成チェックつけられません")
                                        }
                                        
                                    }, label: {
                                        Image(systemName: bucketViewModel.achievement ? "checkmark.square" : "square")
                                            .foregroundColor(Color("originalBlack"))
                                    })
                                    .buttonStyle(.plain)
                                }
                            }
                            
                        }
                .background(Color.gray.opacity(0.1))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color("\(listColor)"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        if bucketViewModel.updateList == nil {
                            Text("リスト作成")
                                .font(.title3)
                                .foregroundColor(Color("originalBlack"))
                            
                        } else {
                            Text("リスト編集")
                                .font(.title3)
                                .foregroundColor(Color("originalBlack"))
                        }
                        
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

    extension AddListView {
        private var bucketTextField: some View {

            TextField("やりたいこと/欲しいもの など", text: $bucketViewModel.text)
                .focused($textFieldIsActive, equals: .text)
                .onTapGesture {
                    textFieldIsActive = nil
                }
            
        }
        
        private var categoryPicker: some View {
            
            Picker("カテゴリー", selection: $bucketViewModel.category) {
                ForEach(categorys, id: \.self) { category in
                    Text("\(category.unwrappedCategoryName)")
                        .tag(category.unwrappedCategoryName)
                }
            }
        }
        
        private var bucketMiniMemoTextField: some View {
            TextField("一言メモ", text: $bucketViewModel.miniMemo)
                .focused($textFieldIsActive, equals: .miniMemo)
                .onTapGesture {
                    textFieldIsActive = nil
                }
        }
        
        private var writeListButton: some View {
            Button(action: {
             
                bucketViewModel.writeList(context: context)
                
                dismiss()
                
                bucketViewModel.resetList()

            }, label: {
                Text(bucketViewModel.updateList == nil ? "作成" : "変更")
                    .font(.title3)
                    .foregroundColor(Color("originalBlack"))
            })
        }
        
        private var cancelButton: some View {
            Button(action: {
                dismiss()
                bucketViewModel.resetList()
            }, label: {
                Image(systemName: "clear.fill")
                    .font(.title2)
                    .foregroundColor(Color("originalBlack"))
            })
        }
        
        private func firstCategoryGet() {
            let arrayCategory = Array(categorys)
            bucketViewModel.category = arrayCategory.first?.categoryName ?? ""
        }
    }

