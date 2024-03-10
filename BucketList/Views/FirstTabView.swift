//
//  FirstTabView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct FirstTabView: View {
    @StateObject var bucketViewModel = BucketViewModel()
    
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        TabView {
            FolderView(bucketViewModel: bucketViewModel)
                .tabItem {
                    Label("フォルダー", systemImage: "folder")

                }
            
            SettingView(bucketViewModel: bucketViewModel)
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
