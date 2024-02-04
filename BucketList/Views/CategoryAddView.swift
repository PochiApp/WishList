//
//  CategoryAddView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/04.
//

import SwiftUI

struct CategoryAddView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.categoryAddDate, ascending: true)],
        animation: .default)
    private var categorys: FetchedResults<CategoryEntity>
    
    var body: some View {
        Form {
            ForEach(categorys){ category in
                Text("\(category.categoryName!)")
            }
        }
    }
}
