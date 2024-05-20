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
    @ObservedObject var wishListViewModel : WishListViewModel
    @Binding var isShowSetPassView: Bool
    @Binding var isShowUnlockPassView: Bool
    @State var canTapDecisionButton: Bool = true
    let UINFGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack {
            //アンロック時のパスコード入力か新規パスコードの設定のどちらかを判定してText表示
            isShowUnlockPassView ? Text("設定しているパスコードを入力してください") : Text("パスコードを設定してください")
            
            //新規パスコード設定の場合、4桁のパスコードが入力すると表示される
            if isShowSetPassView {
                displayPassNumberView
            } else {
                //アンロックの場合、4つのキーImageの表示
                fourKeysImageView
            }
            
            //オリジナルテンキーの表示
            numberButtonView
            
            //新規パスコード設定時は、下に決定ボタンを表示(4桁入力するまでボタンは無効)
            if isShowSetPassView {
                decisionButton
            }
        }
        .onChange(of: passCode) { newPassCode in
            let tuple = (isShowSetPassView, isShowUnlockPassView)
            
            //タプルで、新規パスコード設定かアンロック設定かで分岐処理
            switch tuple {
            
            //新規パスコード設定がtrueの時
            case (true, false):
                let passCodeAray = Array(newPassCode)
                passNumber1 = passCodeAray.indices.contains(0) ? String(passCodeAray[0]) : ""
                passNumber2 = passCodeAray.indices.contains(1) ? String(passCodeAray[1]) : ""
                passNumber3 = passCodeAray.indices.contains(2) ? String(passCodeAray[2]) : ""
                passNumber4 = passCodeAray.indices.contains(3) ? String(passCodeAray[3]) : ""
                
                if newPassCode.count >= 4 {
                    canTapDecisionButton = false
                    passCode = String(newPassCode.prefix(4))
                } else {
                    canTapDecisionButton = true
                }
                
            //アンロック設定がtrueの時
            case (false, true):
                if newPassCode.count == 4 {
                    if newPassCode == wishListViewModel.lockFolder.unwrappedfolderPassword {
                        //キーが4つ色が変わる前に処理が進んでしまうので、0.5sec判定処理を遅らせている。
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            isShowUnlockPassView = false
                            wishListViewModel.unLockFolder(context: context)
                            passCode = ""
                        }
                    } else {
                        //キーが4つ色が変わる前に処理が進んでしまうので、0.5sec判定処理を遅らせている。
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
    
    //オリジナルテンキーのボタンスタイル
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
    private var displayPassNumberView: some View{
        //入力したパスコードが1文字ずつRectangle内に表示される
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
    }
    
    private var fourKeysImageView: some View{
        //入力したパスコードの文字数に応じてkeyが黒く塗りつぶされる
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
                }
            }
            
            HStack {
                Button(action: {
                    isShowSetPassView = false
                    isShowUnlockPassView = false
                }, label: {
                    Text("キャンセル")
                        .font(.caption)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
                
                Button(action: {
                    passCode += "0"
                }, label: {
                    Text("0")
                        .font(.title2)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
                
                Button(action: {
                    passCode = String(passCode.dropLast())
                }, label: {
                    Image(systemName: "delete.left")
                    
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: wishListViewModel.lockFolder))
            }
        }
    }
    
    private var decisionButton: some View {
        Button(action: {
            //ViewModelに入力したパスコードを渡す
            wishListViewModel.folderPassword = passCode
            isShowSetPassView = false
            //Folder新規パスコード設定
            wishListViewModel.lockFolder(context: context)
        }, label: {
            Text("決定")
        })
        .padding()
        .disabled(canTapDecisionButton) //ボタンの有効/無効管理
    }
}

