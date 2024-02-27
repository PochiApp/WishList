//
//  SettingView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/23.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var bucketViewModel : BucketViewModel
    
    var version: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return "" }
        return version
    }
    
    var build: String {
        guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else { return "" }
        return build
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("設定")) {
                    NavigationLink(destination: CategoryView(bucketViewModel: bucketViewModel)) {
                        Text("カテゴリー編集")
                    }
                    
                    Text("通知設定")
                    
                }
                
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("アプリバージョン情報")
                        Spacer()
                        Text("\(version)(\(build))")
                            .foregroundColor(.gray)
                            .fontWeight(.regular)
                        
                    }
                    
                    
                    Text("レビューを書く")
                    
                    Text("お問い合わせ")
                    
                    Link(destination: URL(string: "https://summer-argon-e25.notion.site/54b9aa4f4e1b4139b4e52b8c732d153a?pvs=4")!) {
                        Text("プライバシーポリシー")
                    }
                    
                    
                    
                    
                }
            }
        }
        
    }
}

