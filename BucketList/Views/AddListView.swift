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
    let categoryList = ["旅行","仕事","美容","お金"]
    @State private var textFieldText: String = ""
    @ObservedObject var bucketViewModel : BucketViewModel
    @Binding var isShowListAdd: Bool
    
    var body: some View {
        VStack {
            
            NavigationStack{
                Text("やりたいこと")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                bucketTextField
                
                Text("カテゴリー")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                categoryPicker
                
                Text("＞カテゴリー追加")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom,30)
                
                Button(action: {
                    bucketViewModel.writeList(context: context)
                    
                    dismiss()
                    
                }, label: {
                    Text("作成")
                        .font(.title2)
                })
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.gray, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("やりたいことリスト作成")
                            .font(.title3)
                        
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        cancelButton
                    }
                }
            }
        }
    }
}

extension AddListView {
    private var bucketTextField: some View {
        TextField("", text: $bucketViewModel.text)
            .frame(maxHeight: 40, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .padding(.bottom,10)
    }
    
    private var categoryPicker: some View {
        Picker("カテゴリーを選択", selection: $bucketViewModel.category) {
            ForEach(categoryList, id: \.self) { category in
                Text(category)
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
        .background(Color(uiColor: .secondarySystemBackground))

    }
    
    private var cancelButton: some View {
        Button(action: {
            isShowListAdd = false
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title2)
                .foregroundColor(.black)
        })
    }
}
