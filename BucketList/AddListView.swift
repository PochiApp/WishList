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
            HStack {
                Button(action: {
                    isShowListAdd = false
                }, label: {
                    Image(systemName: "clear")
                        .font(.title2)
                        .frame(width: 350, height: 50, alignment: .trailing)
                })
                
            }
            
            Text("やりたいこと")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("", text: $textFieldText)
                .frame(maxHeight: 40, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))
                .padding(.bottom,10)
            Text("カテゴリー")
                 .font(.title3)
                 .frame(maxWidth: .infinity, alignment: .center)
            Picker("カテゴリーを選択", selection: $selectionValue) {
                Text("旅行").tag(1)
                Text("お金").tag(2)
            }
                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                .background(Color(uiColor: .secondarySystemBackground))
                .padding(.bottom,30)
            
            Button(action: {}, label: {
                Text("追加")
                    .font(.title2)
            })
            
        }
    }
}
