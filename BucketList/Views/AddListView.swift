//
//  AddListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

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
    @FocusState var textIsActive: Bool
    
    var body: some View {
        VStack {
            
            NavigationStack{
                Form {
                    Section {
                        bucketTextField
                    }
                    
                    Section {
                        categoryPicker
                        
                        NavigationLink(destination: CategoryView(bucketViewModel: bucketViewModel)){
                            Text("カテゴリー追加へ")
                                .font(.subheadline)
                        }
                    }
                    
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(listColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("やりたいことリスト作成")
                            .font(.title3)
                        
                    }
                    ToolbarItem(placement: .topBarLeading){
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            bucketViewModel.writeList(context: context)
                            
                            dismiss()
                            
                        }, label: {
                            Text("作成")
                                .font(.title3)
                                .foregroundColor(.black)
                        })
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
