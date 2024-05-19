//
//  AddCategoryView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/05.
//

import SwiftUI

struct AddCategoryView: View {
    
    @Environment (\.managedObjectContext)private var context
    @Environment (\.dismiss) var dismiss
    @FocusState var textIsActive: Bool
    
    @ObservedObject var wishListViewModel : WishListViewModel
    
    @Binding var isShowCategoryAdd: Bool
    
    var body: some View {
        VStack(alignment:.center) {
            NavigationStack{
                Form {
                    Section(header: Text("カテゴリー名")) {
                        categoryTextField
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.gray.opacity(0.1))
                .toolbarBackground(.white, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("カテゴリー追加")
                            .font(.title3)
                    }
                    
                    ToolbarItem(placement: .topBarLeading){
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .topBarTrailing){
                        writeCategoryButton
                    }
                }
                .onTapGesture {
                    textIsActive = false
                }
            }
        }
    }
}

extension AddCategoryView {
    private var categoryTextField: some View {
        TextField("", text: $wishListViewModel.categoryName)
            .focused($textIsActive)
            .frame(alignment: .center)
    }
    
    
    private var cancelButton: some View {
        Button(action: {
            isShowCategoryAdd = false
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title2)
                .foregroundColor(Color("originalBlack"))
        })
    }
    
    private var writeCategoryButton: some View {
        Button(action: {
            wishListViewModel.addCategory(context: context)
            
            dismiss()
            
            wishListViewModel.categoryName = ""
        }, label: {
            Text("追加")
                .foregroundColor(Color("originalBlack"))
                .font(.title3)
        })
    }
}
