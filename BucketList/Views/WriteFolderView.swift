//
//  WriteFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI
import CoreData

struct WriteFolderView: View {
        
        @Environment (\.managedObjectContext)private var context
        @Environment (\.dismiss) var dismiss
        @ObservedObject var folderViewModel : FolderViewModel
        @State var inputTitle: String = ""
        @Binding var isShowFolderWrite: Bool
        @FocusState var textIsActive: Bool
        
        var body: some View {
            VStack {
                NavigationStack{
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
                    
                    
                   addFolderButton
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.gray.opacity(0.5), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar{
                        ToolbarItem(placement: .principal){
                            Text("新規フォルダ作成")
                                .font(.title3)
                            
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            
                            cancelButton
                            
                            }
                            
                    }
                    
                }
                .onTapGesture {
                    textIsActive = false
                }
            }
        }
    }



extension WriteFolderView {
    
    private var titleTextField : some View {
        TextField("", text: $folderViewModel.title)
            .frame(maxWidth: 350, maxHeight: 40, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .textFieldStyle(.roundedBorder)
            .focused($textIsActive)
            .padding(.bottom,10)
    }
    
    private var startDatePicker : some View {
        DatePicker(selection: $folderViewModel.selectedStartDate,
                    displayedComponents: [.date]
            ){
                HStack {
                    Image(systemName: "calendar")
                    Text("開始")
                }
                
                    
            }
            .datePickerStyle(.compact)
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .fixedSize()
            .accentColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
    }
    
    private var finishDatePicker : some View {
        DatePicker(selection: $folderViewModel.selectedFinishDate,
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
        Picker("色を選択", selection:$folderViewModel.backColor){
                Text("white").tag(0)
                    .frame(maxWidth:300)
                    .background(Color.white)
                Text("red").tag(1)
                    .frame(maxWidth:300)
                    .background(Color.red.opacity(0.7))
                Text("orange").tag(2)
                    .frame(maxWidth:300)
                    .background(Color.orange.opacity(0.5))
                Text("yellow").tag(3)
                    .frame(maxWidth:300)
                    .background(Color.yellow.opacity(0.5))
                Text("green").tag(4)
                    .frame(maxWidth:300)
                    .background(Color.green.opacity(0.5))
                Text("mint").tag(5)
                    .frame(maxWidth:300)
                    .background(Color.mint.opacity(0.5))
                Text("teal").tag(6)
                    .frame(maxWidth:300)
                    .background(Color.teal.opacity(0.5))
                Text("cyan").tag(7)
                    .frame(maxWidth:300)
                    .background(Color.cyan.opacity(0.6))
                Text("blue").tag(8)
                    .frame(maxWidth:300)
                    .background(Color.blue.opacity(0.5))
                Text("indigo").tag(9)
                    .frame(maxWidth:300)
                    .background(Color.indigo.opacity(0.5))
                Text("purple").tag(10)
                    .frame(maxWidth:300)
                    .background(Color.purple.opacity(0.5))
                Text("pink").tag(11)
                    .frame(maxWidth:300)
                    .background(Color.pink.opacity(0.2))
                Text("brown").tag(12)
                    .frame(maxWidth:300)
                    .background(Color.brown.opacity(0.5))
                Text("gray").tag(13)
                    .frame(maxWidth:300)
                    .background(Color.gray.opacity(0.3))
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth:.infinity, maxHeight: 90)
            .padding(.bottom)
    }
    
    private var cancelButton : some View {
        Button(action: {
            isShowFolderWrite = false
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title3)
                .foregroundColor(.black)
        })
    }
    
    private var addFolderButton : some View {
        Button(action: {
            
            folderViewModel.writeFolder(context: context)
            
            dismiss()
            
        }, label: {
            Text("保存")
                .font(.title2)
                .foregroundColor(.blue)
        })
    }
}
