//
//  FirstTabView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct FirstTabView: View {
    init() {
        //TabBarの背景色を白に変更
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        TabView {
            FolderView()
                .tabItem {
                    Label("フォルダー", systemImage: "folder")
                }
            
            SettingView()
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
