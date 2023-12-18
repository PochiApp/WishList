//
//  AddListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct AddListView: View {
    
    @State private var textFieldText: String = ""
    @State private var selectionValue = 1
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
                
                Button(action: {}, label: {
                    Text("作成")
                        .font(.title2)
                })
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.gray, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("新規フォルダ作成")
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
        TextField("", text: $textFieldText)
            .frame(maxHeight: 40, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .padding(.bottom,10)
    }
    
    private var categoryPicker: some View {
        Picker("カテゴリーを選択", selection: $selectionValue) {
            Text("旅行").tag(1)
            Text("仕事").tag(2)
            Text("美容").tag(3)
            
        }
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
