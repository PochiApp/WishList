//
//  WishListApp.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData

@main
struct WishListApp: App {
    private let persistence = PersistenceController.shared
        var body: some Scene {
            WindowGroup {
                FirstTabView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
        }
}