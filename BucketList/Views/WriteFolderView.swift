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
        @ObservedObject var bucketViewModel : BucketViewModel
        @Binding var isShowFolderWrite: Bool
        @FocusState var textIsActive: Bool
        @State private var daySetting = true
        
        var body: some View {
            VStack {
                NavigationStack{
                    Form {
                        
                        Section {
                            
                            titleTextField
                        }
                        
                        
                        Section {
                            startDatePicker
                            
                            finishDatePicker
                            
                            Toggle("期間設定なし", isOn: $daySetting)
                            
                        } header: {
                            Text("期間")
                        }
                        
                        Section {
                            colorPicker
                        } header: {
                            Text("背景色")
                        }
                        

                    }
                    
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(bucketViewModel.colorList[bucketViewModel.backColor], for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar{
                        ToolbarItem(placement: .principal){
                            if bucketViewModel.updateFolder == nil {
                                Text("新規フォルダ作成")
                                    .font(.title3)
                            } else {
                                Text("フォルダ編集")
                            }
                            
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            
                            cancelButton
                            
                            }
                        ToolbarItem(placement: .topBarTrailing) {
                            
                            addFolderButton
                            
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
        TextField("フォルダータイトル", text: $bucketViewModel.title)
            .focused($textIsActive)

    }
    
    private var startDatePicker : some View {
        DisclosureGroup(daySetting ?"開始  \(bucketViewModel.formattedDateString(date: bucketViewModel.selectedStartDate))" : "開始　未設定"){
                DatePicker("開始",selection: $bucketViewModel.selectedStartDate, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
            
        }
                     .disabled(!daySetting)
    }
    
    private var finishDatePicker : some View {
        DisclosureGroup(daySetting ?"終了  \(bucketViewModel.formattedDateString(date: bucketViewModel.selectedStartDate))" : "終了　未設定"){
            DatePicker("終了",selection: $bucketViewModel.selectedFinishDate, in: bucketViewModel.selectedStartDate..., displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
                    .disabled(!daySetting)
    }
                
    
    private var colorPicker : some View {
        Picker("色を選択", selection:$bucketViewModel.backColor){
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
            
            bucketViewModel.resetFolder()
            
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title3)
                .foregroundColor(.black)
        })
    }
    
    private var addFolderButton : some View {
        Button(action: {
            
            bucketViewModel.writeFolder(context: context)
            
            dismiss()
            
            
        }, label: {
            Text("追加")
                .font(.title3)
                .foregroundColor(.black)
        })
    }
}
