//
//  AddFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct AddFolderView: View {

        
        @State var textFieldTitle: String = ""
        
        var body: some View {
            VStack {
                
                
                Text("タイトル")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                TextField("", text: $textFieldTitle)
                    .frame(maxHeight: 40, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .padding(.bottom,10)
                
                Text("期限")
                
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
               
                
                Button(action: {}, label: {
                    Text("追加")
                        .font(.title2)
                })
                
            }
        }
    }

#Preview {
    AddFolderView()
}
