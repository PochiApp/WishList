//
//  iCloudSettingView.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/10/05.
//

import SwiftUI

struct iCloudSettingView: View {
    @AppStorage("isICloudEnabled") private var isICloudEnabled = false
    @State private var showAlert = false
    @State private var pendingToggleValue = false

    var body: some View {
        Form {
            if !isICloudEnabled {
                Section(header: Text("連携について")) {
                    Text(
                        """
                        iCloudに保存されたデータは、同じApple IDでサインインしているすべてのデバイスで共有されます。

                        - ネットワーク環境により同期に時間がかかる場合があります。
                        - iCloudを無効にすると、今後はローカルデータのみが使用されます。
                        """
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }

            Toggle(
                isOn: Binding(
                    get: { isICloudEnabled },
                    set: { newValue in
                        // すぐには切り替えず、確認アラートを出す
                        pendingToggleValue = newValue
                        showAlert = true
                    }
                )
            ) {
                Label("iCloudを有効にする", systemImage: "icloud")
            }
        }
        .navigationTitle("iCloud連携設定")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(
                    pendingToggleValue
                        ? "iCloud連携を有効にしますか？" : "iCloud連携を無効にしますか？"
                ),
                message: Text(
                    pendingToggleValue
                        ? "有効にすると、データがiCloudに保存され、他のデバイスと同期されます。"
                        : "無効にすると、iCloudとの同期が停止し、ローカルデータのみが使用されます。"
                ),
                primaryButton: .default(Text("はい")) {
                    withAnimation {
                        isICloudEnabled = pendingToggleValue
                    }
                    if pendingToggleValue {
                        enableICloudSync()
                    } else {
                        disableICloudSync()
                    }
                },
                secondaryButton: .cancel(Text("キャンセル")) {
                    // 元に戻す
                    pendingToggleValue = isICloudEnabled
                }
            )
        }
    }

    // MARK: - iCloud同期制御メソッド

    private func enableICloudSync() {
        print("iCloud同期を有効化しました")
        // CloudKitストアへの切り替え処理などをここに
    }

    private func disableICloudSync() {
        print("iCloud同期を無効化しました")
        // ローカルストアへの戻し処理などをここに
    }
}

#Preview {
    NavigationStack {
        iCloudSettingView()
    }
}
