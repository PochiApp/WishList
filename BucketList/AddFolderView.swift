//
//  AddFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct AddFolderView: View {

        
        @State var textFieldTitle: String = ""
        @State var selectedStartDate = Date()
        @State var selectedColor = Color.white
        
        var body: some View {
            VStack {
                
                
                Text("タイトル")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                titleTextField
                
                Text("期限")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
    
                startDatePicker
                    
                finishDatePicker

                Text("背景色")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                colorPicker
                
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

extension AddFolderView {
    
    private var titleTextField : some View {
        TextField("", text: $textFieldTitle)
            .frame(maxHeight: 40, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .padding(.bottom,10)
    }
    
    private var startDatePicker : some View {
        DatePicker(selection: $selectedStartDate,
                    displayedComponents: [.date]
            ){
                HStack {
                    Image(systemName: "calendar")
                    Text("開始")
                }
                
                    
            }
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .fixedSize()
            .accentColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
    }
    
    private var finishDatePicker : some View {
        DatePicker(selection: $selectedStartDate,
                    displayedComponents: [.date]
            ){
                HStack {
                    Image(systemName: "calendar")
                    Text("終了")
                }
                
                    
            }
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .fixedSize()
            .accentColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
            .padding(.bottom)
    }
    
    private var colorPicker : some View {
        HStack {
            ColorPicker(selection: $selectedColor){
                
            }
                .font(.title)
                .labelsHidden()
                .fixedSize()
                

            Rectangle()
                .fill(selectedColor)
                .frame(width: 300, height: 50)
        }
        .padding(.bottom)
    }
}
