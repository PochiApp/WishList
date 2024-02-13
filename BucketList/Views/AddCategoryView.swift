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
    
    @ObservedObject var bucketViewModel : BucketViewModel
    
    @Binding var isShowCategoryAdd: Bool
    
    var body: some View {
        VStack {
            
            NavigationStack{
                Text("カテゴリー名")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                categoryTextField
                
                Button(action: {
                    bucketViewModel.addCategory(context: context)
                    
                    dismiss()
                    
                }, label: {
                    Text("追加")
                        .font(.title2)
                })
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.white, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("カテゴリー追加")
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

extension AddCategoryView {
    private var categoryTextField: some View {
        TextField("", text: $bucketViewModel.categoryName)
            .frame(maxHeight: 40, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .padding(.bottom,10)
    }
    
    
    private var cancelButton: some View {
        Button(action: {
            isShowCategoryAdd = false
        }, label: {
            Image(systemName: "clear.fill")
                .font(.title2)
                .foregroundColor(.black)
        })
    }
}
