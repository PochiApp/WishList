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
    
    @State private var textFieldText: String = ""
    @State private var textFieldMemo: String = ""
    @ObservedObject var bucketViewModel : BucketViewModel
    @Binding var isShowListAdd: Bool
    @State var listColor: String
    @State var selectedPhoto: [PhotosPickerItem] = []
    @FocusState var textIsActive: Bool
    @FocusState var memoIsActive: Bool
    
    
    var body: some View {
        VStack {
            
            NavigationStack{
                Form {
                    Section(header: Text("やりたいこと")) {
                        let _ = print("a")
                        bucketTextField
                        
                        let _ = print("b")
                    }
                    
                    Section(header: Text("カテゴリー")) {
                        categoryPicker
                        
                        NavigationLink(destination: CategoryView(bucketViewModel: bucketViewModel)){
                            Text("カテゴリー追加へ")
                                .font(.subheadline)
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
                        .onChange(of: selectedPhoto){
                            
                            
                        
                            if !bucketViewModel.datas.isEmpty {
                                bucketViewModel.datas.removeAll()
                            }
                            
                            Task {
                                await bucketViewModel.convertDataimages(photos: selectedPhoto)
                                
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
                            Text("やりたいことリスト作成")
                                .font(.title3)
                        } else {
                            Text("やりたいことリスト編集")
                                .font(.title3)
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
        .onTapGesture {
            textIsActive = false
            memoIsActive = false
        }
            }
        
        }
    
    

    
    extension AddListView {
        private var bucketTextField: some View {

            TextField("やりたいこと", text: $textFieldText)
                .focused($textIsActive)
            
        }
        
        private var categoryPicker: some View {
            
            Picker("カテゴリー", selection: $bucketViewModel.category) {
                ForEach(categorys, id: \.self) { category in
                    Text("\(category.categoryName ?? "")")
                        .tag(category.categoryName ?? "")
                }
            }
        }
        
        private var bucketMiniMemoTextField: some View {
            TextField("一言メモ", text: $textFieldMemo)
                .focused($memoIsActive)
        }
        
        private var writeListButton: some View {
            Button(action: {
                bucketViewModel.text = textFieldText
                bucketViewModel.miniMemo = textFieldMemo
                bucketViewModel.writeList(context: context)
                
                dismiss()
                
                bucketViewModel.resetList()
            }, label: {
                Text("作成")
                    .font(.title3)
                    .foregroundColor(Color("originalBlack"))
            })
        }
        
        private var cancelButton: some View {
            Button(action: {
                isShowListAdd = false
                bucketViewModel.resetList()
            }, label: {
                Image(systemName: "clear.fill")
                    .font(.title2)
                    .foregroundColor(Color("originalBlack"))
            })
        }
    }

