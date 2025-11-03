//
//  LaunchScreen.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/10/26.
//

import CoreData
import SwiftUI
import UIKit

struct LaunchScreen: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject var loadingViewModel = LoadingViewModel()
    @AppStorage("isICloudEnabled") var isICloudEnabled = false
    @State var showProgress = true

    var body: some View {
        if showProgress {
            ZStack {
                Color("splashBack")
                    .ignoresSafeArea()  // ステータスバーまで塗り潰すために必要
                VStack {
                    iconImage
                    
                    if showProgress {
                        loadingAnimation
                    }
                }
            }
            .task {
                if !isICloudEnabled {
                    // iCloud連携したいない場合はLaunchScreenを閉じる
                    return showProgress = false
                }
                if let iCloudContainer = PersistenceController.shared.iCloudContainer {
                    // iCloudのデータをCoreDataのローカルキャッシュに同期したことの確認
                    await loadingViewModel.startCloudSync(iCloudContainer)
                    // フェッチが完了したことの確認
                    await loadingViewModel.waitUntilFetched(context: context)
                    showProgress = false
                }
            }
        } else {
            FirstTabView()
        }
    }
}

extension LaunchScreen {
    private var iconImage: some View {
        Image("Icon")
            .resizable()
            .scaledToFit()  // アスペクト比を維持してフィット
            .frame(width: UIScreen.main.bounds.width * 0.35)
            .padding()
    }
    
    private var loadingAnimation: some View {
            VStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("読み込み中…")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .transition(.opacity)
    }
}
