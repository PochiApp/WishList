//
//  CategoryViewModel.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/08/28.
//

import SwiftUI
import CoreData

class CategoryViewModel: ObservableObject {
    //Category関連
    @Published var categoryName = ""
    @Published var categoryAddDate = Date()
    
    //MARK: - カテゴリー関連メソッド
    //Category追加処理
    func addCategory(context: NSManagedObjectContext) {
        let newCategoryEntity = CategoryEntity(context: context)
        newCategoryEntity.categoryName = categoryName
        newCategoryEntity.categoryAddDate = Date()
        
        do {
            try context.save()
        }
        catch {
            print("カテゴリー追加できませんでした")
        }
    }
    
    //Category保存処理
    func saveCategory(context: NSManagedObjectContext) {
        do {
            try context.save()
        }
        catch {
            print("カテゴリーの保存ができませんでした")
        }
    }
    
    //Category保存処理
    func rollbackCategory(context: NSManagedObjectContext) {
        context.rollback()
    }
}
