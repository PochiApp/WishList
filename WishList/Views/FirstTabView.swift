//
//  FirstTabView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct FirstTabView: View {
    //ViewModelのインスタンス作成 これを各Viewに引数で渡してViewModelにアクセスできるようにする
    @StateObject var wishListViewModel = WishListViewModel()
    
    init() {
        //TabBarの背景色を白に変更
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
        .accentColor(Color("originalBlack")) //TabBarの文字色変更
    }
}

#Preview {
    FirstTabView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
