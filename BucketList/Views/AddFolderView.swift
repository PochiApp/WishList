//
//  AddFolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI

struct AddFolderView: View {
        
        @Environment (\.managedObjectContext)private var context
        @ObservedObject var folderViewModel : FolderViewModel
    
        @State var textFieldTitle: String = ""
        @State var selectedStartDate = Date()
        @State var selectedFinishDate = Date()
        @State var selectedColor = Color.white
        @Binding var isShowFolderAdd : Bool
        
    
        let fm: FolderViewModel = FolderViewModel()
        
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
                    
                    
                    Button(action: {
                        folderViewModel.addData(context: context)
                    }, label: {
                        Text("作成")
                            .font(.title2)
                            .foregroundColor(.blue)
                    })
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.gray, for: .navigationBar)
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
            }
        }
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
        DatePicker(selection: $selectedFinishDate,
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
        Picker("色を選択", selection:$selectedColor){
                Text("white").tag(Color.white)
                    .frame(maxWidth:300)
                    .background(Color.white)
                Text("red").tag(Color.red)
                    .frame(maxWidth:300)
                    .background(Color.red.opacity(0.7))
                Text("orange").tag(Color.orange)
                    .frame(maxWidth:300)
                    .background(Color.orange.opacity(0.5))
                Text("yellow").tag(Color.yellow)
                    .frame(maxWidth:300)
                    .background(Color.yellow.opacity(0.5))
                Text("green").tag(Color.green)
                    .frame(maxWidth:300)
                    .background(Color.green.opacity(0.5))
                Text("mint").tag(Color.mint)
                    .frame(maxWidth:300)
                    .background(Color.mint.opacity(0.5))
                Text("teal").tag(Color.teal)
                    .frame(maxWidth:300)
                    .background(Color.teal.opacity(0.5))
                Text("cyan").tag(Color.cyan)
                    .frame(maxWidth:300)
                    .background(Color.cyan.opacity(0.6))
                Text("blue").tag(Color.blue)
                    .frame(maxWidth:300)
                    .background(Color.blue.opacity(0.5))
                Text("indigo").tag(Color.indigo)
                    .frame(maxWidth:300)
                    .background(Color.indigo.opacity(0.5))
                Text("purple").tag(Color.purple)
                    .frame(maxWidth:300)
                    .background(Color.purple.opacity(0.5))
                Text("pink").tag(Color.pink)
                    .frame(maxWidth:300)
                    .background(Color.pink.opacity(0.2))
                Text("brown").tag(Color.brown)
                    .frame(maxWidth:300)
                    .background(Color.brown.opacity(0.5))
                Text("gray").tag(Color.gray)
                    .frame(maxWidth:300)
                    .background(Color.gray.opacity(0.3))
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth:.infinity, maxHeight: 90)
            .padding(.bottom)
    }
    
    private var cancelButton : some View {
        Button(action: {
            isShowFolderAdd = false
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title3)
                .foregroundColor(.black)
        })
    }
    
    private func makeNewFolder() {
//        vm.addNewFolder()
    }
}
