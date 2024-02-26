//
//  SettingView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("設定")) {
                    
                    Text("カテゴリー編集")
                    
                    
                }
                
                Section(header: Text("アプリ情報")) {
                    Text("アプリバージョン情報")
                    
                    Text("レビューを書く")
                    
                    
                }
            }
        }
        
    }
}

#Preview {
    SettingView()
}
