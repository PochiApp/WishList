//
//  FirstTabView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct FirstTabView: View {
    @StateObject var wishListViewModel = WishListViewModel()
    
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        TabView {
            FolderView(wishListViewModel: wishListViewModel)
                .tabItem {
                    Label("フォルダー", systemImage: "folder")

                }
            
            SettingView(wishListViewModel: wishListViewModel)
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
            
            
        }
        .background(.white)
        .accentColor(Color("originalBlack"))
    }
}

#Preview {
    FirstTabView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
