//
//  SetPassView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/12.
//

import SwiftUI
import AudioToolbox

struct SetPassView: View {
    
    @Environment(\.managedObjectContext) private var context
    @State var passCode = ""
    @State var passNumber1 = ""
    @State var passNumber2 = ""
    @State var passNumber3 = ""
    @State var passNumber4 = ""
    @ObservedObject var bucketViewModel : BucketViewModel
    @Binding var isShowSetPassPage: Bool
    @Binding var isShowUnlockPassPage: Bool
    @State var isDisable: Bool = true
    let UINFGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack {
                isShowUnlockPassPage ? Text("設定しているパスコードを入力してください") : Text("パスコードを設定してください")
            
            if isShowSetPassPage {
                HStack {
                    Rectangle()
                        .stroke(lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay(Text("\(passNumber1)").fontWeight(.bold))
                    
                    Rectangle()
                        .stroke(lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay(Text("\(passNumber2)").fontWeight(.bold))
                    
                    Rectangle()
                        .stroke(lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay(Text("\(passNumber3)").fontWeight(.bold))
                    
                    Rectangle()
                        .stroke(lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay(Text("\(passNumber4)").fontWeight(.bold))
                        
                    }
                        .padding()
               
            } else {
                HStack {
                    Image(systemName: passCode.count >= 1 ? "key.fill" : "key")
                        .font(.system(size:30))
                        .padding()
                    
                    Image(systemName: passCode.count >= 2 ? "key.fill" : "key")
                        .font(.system(size:30))
                        .padding()
                    
                    Image(systemName: passCode.count >= 3 ? "key.fill" : "key")
                        .font(.system(size:30))
                        .padding()
                    
                    Image(systemName: passCode.count >= 4 ? "key.fill" : "key")
                        .font(.system(size:30))
                        .padding()
                }
                .padding()
            }
            
                numberButtonView
            
            if isShowSetPassPage {
                Button(action: {
                    bucketViewModel.folderPassword = passCode
                    isShowSetPassPage = false
                    bucketViewModel.lockFolder(context: context)
                }, label: {
                    Text("決定")
                })
                .padding()
                .disabled(isDisable)
            }
                }
        .onChange(of: passCode) {
            let tuple = (isShowSetPassPage, isShowUnlockPassPage)
            
            switch tuple {
            
            case (true, false):
                let passCodeAray = Array(passCode)
                passNumber1 = passCodeAray.indices.contains(0) ? String(passCodeAray[0]) : ""
                passNumber2 = passCodeAray.indices.contains(1) ? String(passCodeAray[1]) : ""
                passNumber3 = passCodeAray.indices.contains(2) ? String(passCodeAray[2]) : ""
                passNumber4 = passCodeAray.indices.contains(3) ? String(passCodeAray[3]) : ""
                
                if passCode.count >= 4 {
                    isDisable = false
                    passCode = String(passCode.prefix(4))
                } else {
                    isDisable = true
                }
                
            case (false, true):
                if passCode.count == 4 {
                    if passCode == bucketViewModel.lockFolder.unwrappedfolderPassword {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            isShowUnlockPassPage = false
                            bucketViewModel.unLockFolder(context: context)
                            passCode = ""
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            UINFGenerator.notificationOccurred(.warning)
                            passCode = ""
                        }
                    }
                }
                
            default: break
            }
            
        }
        }
    
    struct CapsuleButtonStyle: ButtonStyle {
        
        @State var selectedFolder: FolderModel
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(8)
                .frame(width: 80, height: 80)
                .background(configuration.isPressed ? Color("snowWhite") : Color("\(selectedFolder.unwrappedBackColor)"))
                .foregroundColor(Color("originalBlack"))
                .font(.body.bold())
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .padding(.horizontal, 8)
                .padding(.bottom, 3)
                
        }
    }
    
}

extension SetPassView {
    private var numberButtonView: some View {
        VStack(alignment: .trailing) {
            HStack {
                ForEach(1...3, id: \.self) { number in
                    Button(action: {
                        passCode += "\(number)"
                    }, label: {
                        Text("\(number)")
                            .font(.title2)
                    })
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
                }
            }
            
            HStack {
                ForEach(4...6, id: \.self) { number in
                    Button(action: {
                        passCode += "\(number)"
                    }, label: {
                        Text("\(number)")
                            .font(.title2)
                    })
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
                }
            }
            
            HStack {
                ForEach(7...9, id: \.self) { number in
                    Button(action: {
                        passCode += "\(number)"
                    }, label: {
                        Text("\(number)")
                            .font(.title2)
                    })
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
                }
            }
            
            HStack {
                Button(action: {
                    isShowSetPassPage = false
                    isShowUnlockPassPage = false
                }, label: {
                    Text("キャンセル")
                        .font(.caption)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
                
                Button(action: {
                    passCode += "0"
                }, label: {
                    Text("0")
                        .font(.title2)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
                
                Button(action: {
                    passCode = String(passCode.dropLast())
                }, label: {
                    Image(systemName: "delete.left")
    
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: bucketViewModel.lockFolder))
            }
        }
    }
}

