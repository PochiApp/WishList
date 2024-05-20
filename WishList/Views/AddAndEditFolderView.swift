//
//  AddAndEditFolderView.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2023/12/16.
//

import SwiftUI
import CoreData

struct AddAndEditFolderView: View {
    
    @Environment (\.managedObjectContext)private var context
    @Environment (\.dismiss) var dismiss
    @ObservedObject var wishListViewModel : WishListViewModel
    @Binding var isShowAddAndEditFolderView: Bool
    @FocusState var textIsActive: Bool
    @State private var folderTitle: String = ""
    
    var body: some View {
        VStack {
            NavigationStack{
                Form {
                    Section(header: Text("フォルダータイトル")) {
                        folderTitleTextField
                    }
                    
                    Section(header: Text("期間")) {
                        startDatePicker
                        finishDatePicker
                        Toggle("期間設定なし", isOn: $wishListViewModel.notDaySetting)
                    }
                    
                    Section(header: Text("テーマカラー")) {
                        folderThemeColorPicker
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color("\(wishListViewModel.backColor)"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        navigationBarTitle
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
                //TextField外をタップしたら、フォーカス状態をOFFにしてキーボードを閉じる
                textIsActive = false
            }
        }
    }
}


//MARK: - extension
extension AddAndEditFolderView {
    
    private var folderTitleTextField : some View {
        TextField("フォルダ-タイトル", text: wishListViewModel.updateFolder == nil ? $folderTitle : $wishListViewModel.folderTitle)
            .focused($textIsActive)
        
    }
    
    private var startDatePicker : some View {
        DisclosureGroup(wishListViewModel.notDaySetting ?"開始　未設定" :"開始  \(wishListViewModel.formattedDateString(date: wishListViewModel.selectedStartDate))"){
            DatePicker("開始",selection: $wishListViewModel.selectedStartDate, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ja_JP"))
            
        }
        .disabled(wishListViewModel.notDaySetting)
    }
    
    private var finishDatePicker : some View {
        DisclosureGroup(wishListViewModel.notDaySetting ?"終了　未設定" :"終了  \(wishListViewModel.formattedDateString(date: wishListViewModel.selectedFinishDate))"){
            DatePicker("終了",selection: $wishListViewModel.selectedFinishDate, in: wishListViewModel.selectedStartDate..., displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
        .disabled(wishListViewModel.notDaySetting)
    }
    
    private var folderThemeColorPicker : some View {
        Picker("色を選択", selection: $wishListViewModel.backColor){
            Text("SnowWhite").tag("snowWhite")
                .frame(maxWidth:300)
                .background(Color("snowWhite"))
            Text("RoseRed").tag("roseRed")
                .frame(maxWidth:300)
                .background(Color("roseRed"))
            Text("Pink").tag("originalPink")
                .frame(maxWidth:300)
                .background(Color("originalPink"))
            Text("GoldenYellow").tag("goldenYellow")
                .frame(maxWidth:300)
                .background(Color("goldenYellow"))
            Text("LemonYellow").tag("lemonYellow")
                .frame(maxWidth:300)
                .background(Color("lemonYellow"))
            Text("Fresh").tag("fresh")
                .frame(maxWidth:300)
                .background(Color("fresh"))
            Text("Vanilla").tag("vanilla")
                .frame(maxWidth:300)
                .background(Color("vanilla"))
            Text("Cinnamon").tag("cinnamon")
                .frame(maxWidth:300)
                .background(Color("cinnamon"))
            Text("LimeLight").tag("limeLight")
                .frame(maxWidth:300)
                .background(Color("limeLight"))
            Text("LettuceGreen").tag("lettuceGreen")
                .frame(maxWidth:300)
                .background(Color("lettuceGreen"))
            Text("AppleGreen").tag("appleGreen")
                .frame(maxWidth:300)
                .background(Color("appleGreen"))
            Text("WaterGreen").tag("waterGreen")
                .frame(maxWidth:300)
                .background(Color("waterGreen"))
            Text("SkyBlue").tag("skyBlue")
                .frame(maxWidth:300)
                .background(Color("skyBlue"))
            Text("Aqua").tag("aqua")
                .frame(maxWidth:300)
                .background(Color("aqua"))
            Text("BlueLavender").tag("blueLavender")
                .frame(maxWidth:300)
                .background(Color("blueLavender"))
            Text("Iris").tag("iris")
                .frame(maxWidth:300)
                .background(Color("iris"))
            Text("Purple").tag("originalPurple")
                .frame(maxWidth:300)
                .background(Color("originalPurple"))
        }
        .pickerStyle(WheelPickerStyle())
        .frame(maxWidth:.infinity, maxHeight: 90)
        .padding(.bottom)
    }
    
    private var navigationBarTitle : some View {
        //updateFolderがnilなら「新規フォルダー作成」, そうでなければ「フォルダー編集」と表示
        if wishListViewModel.updateFolder == nil {
            Text("新規フォルダー作成")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        } else {
            Text("フォルダー編集")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        }
    }
    
    private var cancelButton : some View {
        Button(action: {
            isShowAddAndEditFolderView = false
            
            wishListViewModel.resetFolder()
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        })
    }
    
    private var addFolderButton : some View {
        Button(action: {
            /*updateFolderがnilの場合は、新規作成としてfolderTitleをViewModelのfolderTitleへ代入
             ViewModelのfolderTitleをTextFieldのBinding変数にしてしまうと、テキスト入力時にカクついてしまうので、
             folderTitleはFolder新規作成直前にViewModelに引き渡す形をとっている
             */
            if wishListViewModel.updateFolder == nil {
                wishListViewModel.folderTitle = folderTitle
            }
            wishListViewModel.addNewFolderOrEditFolder(context: context)
            
            dismiss()
            
            wishListViewModel.resetFolder()
        }, label: {
            Text(wishListViewModel.updateFolder == nil ? "追加" : "変更")
                .font(.title3)
                .foregroundColor(Color("originalBlack"))
        })
    }
}
