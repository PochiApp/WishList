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
    @ObservedObject var bucketViewModel : BucketViewModel
    @Binding var isShowListAdd: Bool
    @State var listColor: Color
    
    var body: some View {
        VStack {
            
            NavigationStack{
                Form {
                    Section(header: Text("やりたいこと")) {
                        bucketTextField
                    }
                    
                    Section(header: Text("カテゴリー")) {
                        categoryPicker
                        
                        NavigationLink(destination: CategoryView(bucketViewModel: bucketViewModel)){
                            Text("カテゴリー追加へ")
                                .font(.subheadline)
                        }
                    }
                    
                    Section(header: Text("画像")) {
                        
                        PhotosPicker(selection: $bucketViewModel.selectedPhoto, maxSelectionCount: 2, matching: .images) {
                            if bucketViewModel.images.isEmpty {
                                Image("noimage")
                                    .resizable()
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
                                
                            }
                        }
                        .onChange(of: bucketViewModel.selectedPhoto) {
                            
                            Task {
                                await bucketViewModel.convertDataimages(photos: bucketViewModel.selectedPhoto)
                                await bucketViewModel.convertUiimages()
                            }
                        }
                        
                        
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
                .toolbarBackground(listColor, for: .navigationBar)
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
            }
        
        }
    
    

    
    extension AddListView {
        private var bucketTextField: some View {
            TextField("やりたいこと", text: $bucketViewModel.text)
            
        }
        
        private var categoryPicker: some View {
            
            Picker("カテゴリー", selection: $bucketViewModel.category) {
                ForEach(categorys, id: \.self) { category in
                    Text("\(category.categoryName ?? "")")
                        .tag(category.categoryName ?? "")
                }
            }
        }
        
        private var writeListButton: some View {
            Button(action: {
                bucketViewModel.writeList(context: context)
                
                dismiss()
                
            }, label: {
                Text("作成")
                    .font(.title3)
                    .foregroundColor(.black)
            })
        }
        
        private var cancelButton: some View {
            Button(action: {
                isShowListAdd = false
                bucketViewModel.resetList()
            }, label: {
                Image(systemName: "clear.fill")
                    .font(.title2)
                    .foregroundColor(.black)
            })
        }
    }

