//
//  CategoryView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/04.
//

import SwiftUI
import CoreData

struct CategoryView: View {
    
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var wishListViewModel : WishListViewModel
    
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    @State var isShowCategoryAdd = false
    
    var body: some View {
        NavigationView{
            ZStack{
                if categorys.isEmpty {
                    emptyCategoryView
                }
                List {
                    ForEach(categorys){ category in
                        Text("\(category.unwrappedCategoryName)")
                            .font(.title3)
        
                    }
                    .onDelete(perform: deleteCategory)
                }
                .background(Color.gray.opacity(0.1))
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        floatingButton
                        
                    }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 30))
                }
                
                
                
            }
            
        }
        .navigationTitle("カテゴリー一覧")
        .font(.title3)
        .sheet(isPresented: $isShowCategoryAdd){
            
            AddCategoryView(wishListViewModel: wishListViewModel, isShowCategoryAdd: $isShowCategoryAdd)
                .presentationDetents([.medium])
        
                    
            }
        
    }
    
    
    
    
    private func deleteCategory (offSets: IndexSet) {
        offSets.map { categorys[$0] }.forEach(context.delete)
        
        do {
            try context.save()
            
        }
        catch {
            print("削除失敗")
        }
        
        
    }
    
    
   
}

extension CategoryView {
    private var floatingButton: some View {
        Button(action: {
            isShowCategoryAdd.toggle()
            
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                .font(.system(size: 40))
                .padding()
        })
    }
    
    
    private var emptyCategoryView: some View {
        
        VStack(alignment: .center) {
            Image(systemName: "books.vertical")
                .font(.system(size: 100))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.bottom)
            
            Text("カテゴリーを追加して、リストを分類しましょう")
                .font(.caption)
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }
}
