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
    @ObservedObject var bucketViewModel : BucketViewModel
    
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    @State var isShowCategoryAdd = false
    
    var body: some View {
        NavigationView{
            ZStack{
                List {
                    ForEach(categorys){ category in
                        Text("\(category.categoryName ?? "")")
                            .font(.title3)
        
                    }
                    .onDelete(perform: deleteCategory)
                }
                
                
                Button(action: {
                    isShowCategoryAdd.toggle()
                    
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding()
                })
                
                .sheet(isPresented: $isShowCategoryAdd){
                    
                    AddCategoryView(bucketViewModel: bucketViewModel, isShowCategoryAdd: $isShowCategoryAdd)
                        .presentationDetents([.large, .fraction(0.9)])
                
                            
                    }
                
                
            }
            
        }
        .navigationTitle("カテゴリー一覧")
        .font(.title3)
        .onDisappear(){
        firstCategoryGet()
       }
        
    }
    
    private func deleteCategory (offSets: IndexSet) {
        offSets.map { categorys[$0] }.forEach(context.delete)
        
        do {
            try context.save()
            
            firstCategoryGet()
            
        }
        catch {
            print("削除失敗")
        }
        
        
    }
    
    private func firstCategoryGet () {
        let arrayCategory = Array(categorys)
        let firstCategoryName = arrayCategory.first?.categoryName ?? ""
        bucketViewModel.firstCategory = firstCategoryName
        
        bucketViewModel.category = firstCategoryName
        
    }
}
