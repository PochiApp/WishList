//
//  MailView.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/10/25.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let errorMessage: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["pochi.app.dp@gmail.com"])
        vc.setSubject("アプリエラー報告")
        vc.setMessageBody("発生したエラー:\n\(errorMessage)", isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            // メール送信画面を閉じるだけにする
            controller.dismiss(animated: true)
            
            // 必要ならここでログ送信も可能
            if let error = error {
                print("メール送信エラー: \(error.localizedDescription)")
            } else {
                switch result {
                case .sent:
                    print("送信成功")
                case .cancelled:
                    print("キャンセル")
                case .failed:
                    print("失敗")
                case .saved:
                    print("下書き保存")
                @unknown default:
                    print("不明な状態")
                }
            }
        }
    }
}
