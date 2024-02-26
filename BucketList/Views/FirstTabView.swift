//
//  FirstTabView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct FirstTabView: View {
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
            
            ShareView()
                .tabItem {
                    Label("共有", systemImage: "square.and.arrow.up")
                 
                }
        }
        .accentColor(.black)
    }
}

#Preview {
    FirstTabView()
}
