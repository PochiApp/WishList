//
//  PasscodeView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/02.
//

import SwiftUI

struct PasscodeView: View {

    @State private var passcode: String = ""
    @FocusState var passcodeIsActive: Bool
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var selectedFolder: FolderModel
    @State var isShowMissAlert: Bool = false
    @Binding var isShowPassInputPage: Bool
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Image(systemName: "lock.fill")
                .font(.system(size: 100))
                .foregroundColor(Color.gray.opacity(0.5))
                
            Text("フォルダーは、ロックされています")
                .font(.title3)
                .foregroundColor(Color.gray)
                .lineLimit(1)
                .padding(.bottom)
            
            SecureField("パスワードを入力してください", text: $passcode)
                .textFieldStyle(CustomPasscodeFieldStyle())
                .frame(width: 300)
                .focused($passcodeIsActive)
            
            Button(action: {
                if passcode == selectedFolder.unwrappedfolderPassword {
                    isShowPassInputPage = false
                } else {
                    isShowMissAlert = true
                }
            }, label: {
                Text("確認")
                    .foregroundColor(.blue)
            })
    
                
        }
        .alert("パスワードが間違っています", isPresented: $isShowMissAlert) {
            
            Button("OK") {
                isShowMissAlert = false
                passcode = ""
            }
                
        } message: {
            Text("正しいパスワードを入力してください。")
        }
            .onTapGesture {
                passcodeIsActive = false
        }
    }
}

