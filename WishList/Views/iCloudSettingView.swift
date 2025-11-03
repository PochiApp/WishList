//
//  iCloudSettingView.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/10/05.
//

import CoreData
import SwiftUI

struct iCloudSettingView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject var iCloudViewModel = iCloudSettingViewModel()
    @AppStorage("isICloudEnabled") var isICloudEnabled = false
    @State private var showMailView = false
    @State private var errorMessage: ErrorMessage?
    @State private var errorTitle: String = "iCloud連携失敗しました"

    var body: some View {
        Form {
            if !isICloudEnabled {
                Section(header: Text("連携について")) {
                    Text(
                        """
                        iCloudに保存されたデータは、同じApple IDでサインインしているすべてのデバイスで共有されます。

                        - ネットワーク環境により同期に時間がかかる場合があります。
                        - 一度iCloud連携を有効にすると、以降このデバイスのデータはiCloudと自動同期され、連携解除はできません。
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
                        iCloudViewModel.pendingToggleValue = newValue
                        // iCloudアカウント連携が設定しているか確認
                        Task {
                            let isAvailable =
                                await iCloudViewModel.checkiCloudAccountStatus()
                            if isAvailable {
                                // iCloudアカウント連携済であれば処理継続
                                do {
                                    //iCloudにデータが存在するかを確認
                                    iCloudViewModel.cloudHasData =
                                        try await iCloudViewModel
                                        .checkiCloudHasData()
                                    print(
                                        "cloudHasData: \(iCloudViewModel.cloudHasData)"
                                    )
                                    iCloudViewModel.showAlert = true
                                } catch {
                                    print(
                                        "⚠️ iCloudデータ確認中にエラー発生 error: \(error)"
                                    )
                                    errorTitle =
                                        "iCloudデータ確認中にエラー発生 error: \(error)"
                                    // エラーダイアログ表示
                                    iCloudViewModel.syncFailed = true
                                }
                            } else {
                                // iCloudアカウント連携未設定の場合、iCloudサインインしてください警告アラート表示
                                iCloudViewModel.showAccountAlert = true
                            }
                        }
                    }
                )
            ) {
                Label("iCloudを有効にする", systemImage: "icloud")
            }
        }
        .navigationTitle("iCloud連携設定")
        .disabled(isICloudEnabled)
        // アラート1. iCloudアカウントにサインインしているか確認
        .alert(
            "iCloudアカウント連携が必要です",
            isPresented: $iCloudViewModel.showAccountAlert
        ) {
            Button("OK") {
                // 元に戻す
                iCloudViewModel.pendingToggleValue = isICloudEnabled
                iCloudViewModel.showAccountAlert = false
            }
        } message: {
            Text("この機能を利用するには、端末の設定でiCloudにサインインしてください")
        }
        // アラート2. iCloud連携有効確認
        .alert("iCloud連携を有効にします", isPresented: $iCloudViewModel.showAlert) {
            Button("キャンセル") {
                // 元に戻す
                iCloudViewModel.pendingToggleValue = isICloudEnabled
            }
            Button("OK") {
                Task {
                    await handleICloudToggle()
                }
            }
        } message: {
            Text(
                iCloudViewModel.cloudHasData
                    ? "iCloudにすでにデータが保存されています。iCloudのデータを読み込みますか？\n※現在表示中のデータは上書きされます"
                    : "iCloudにデータはありません。ローカルのデータをiCloudに移行しますか？"
            )
        }
        // アラート3. iCloud連携完了表示
        .alert("iCloud連携完了", isPresented: $iCloudViewModel.syncCompleted) {
            Button("OK") {
                // タイマーで遅延後アプリを終了する
                UIControl().sendAction(
                    #selector(URLSessionTask.suspend),
                    to: UIApplication.shared,
                    for: nil
                )
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {
                    _ in
                    exit(0)
                }
            }
        } message: {
            Text(
                """
                    iCloud連携完了しました。
                    データ更新のため、一度アプリを終了します。
                    再起動してください。
                """
            )
        }
        .alert("iCloud連携失敗", isPresented: $iCloudViewModel.syncFailed) {
            Button("キャンセル") {
                // 元に戻す
                iCloudViewModel.pendingToggleValue =
                    isICloudEnabled
            }

            Button("エラー報告") {
                errorMessage = ErrorMessage(text: errorTitle)
            }
        } message: {
            Text(
                """
                    iCloud連携に失敗しました。
                    改善のためエラー報告を頂けますと幸いです。
                """
            )
        }
        .sheet(item: $errorMessage) { message in
            MailView(errorMessage: message.text)
        }
    }
    
    @MainActor
    private func handleICloudToggle() async {
        if iCloudViewModel.cloudHasData {
            iCloudViewModel.syncCompleted = true
            isICloudEnabled = iCloudViewModel.pendingToggleValue
        } else {
            do {
                try await iCloudViewModel.migrateLocalToCloud(context)
                iCloudViewModel.syncCompleted = true
                isICloudEnabled = iCloudViewModel.pendingToggleValue
            } catch {
                errorTitle = "ローカルからiCloudへの読み込みに失敗 error: \(error)"
                iCloudViewModel.syncFailed = true
            }
        }
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let text: String
}
