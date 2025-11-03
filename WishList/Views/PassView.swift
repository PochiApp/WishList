//
//  PassView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/07.
//

import SwiftUI
import AudioToolbox

struct PassView: View {
    
    @Environment(\.managedObjectContext) private var context
    // 横サイズ取得
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // 縦サイズ取得
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State var passCode = ""
    @State var selectedFolder: FolderModel
    @Binding var isInsertPassViewBeforeListView: Bool
    let UINFGenerator = UINotificationFeedbackGenerator()
    
    // iPad判定
    var isPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var keySize: CGFloat {
        isPad ? 60 : 30
    }
    
    var body: some View {
        fourKeysImageView
        
        numberButtonView
            .onChange(of: passCode) { newPassCode in
                if newPassCode.count == 4 {
                    if newPassCode == selectedFolder.unwrappedfolderPassword {
                        //キーが4つ色が変わる前に処理が進んでしまうので、0.5sec判定処理を遅らせている。
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            //PassViewの表示を消してListViewを表示するためのフラグ
                            isInsertPassViewBeforeListView = false
                            
                            passCode = ""
                        }
                    } else {
                        //キーが4つ色が変わる前に処理が進んでしまうので、0.5sec判定処理を遅らせている。
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            //振動で間違えていることを知らせる。
                            UINFGenerator.notificationOccurred(.warning)
                            
                            passCode = ""
                        }
                    }
                }
            }
    }
}

struct CapsuleButtonStyle: ButtonStyle {
    
    @State var selectedFolder: FolderModel
    var isPad: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .frame(width: isPad ? 100 : 80, height: isPad ? 100 : 80)
            .background(configuration.isPressed ? Color("snowWhite") : Color("\(selectedFolder.unwrappedBackColor)"))
            .foregroundColor(Color("originalBlack"))
            .font(.body.bold())
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .padding(.horizontal, isPad ? 20 : 8)
            .padding(.bottom, isPad ? 6 : 3)
        
    }
}

extension PassView {
    private var fourKeysImageView: some View{
        VStack {
            HStack {
                Image(systemName: passCode.count >= 1 ? "key.fill" : "key")
                    .font(.system(size: keySize))
                    .padding()
                
                Image(systemName: passCode.count >= 2 ? "key.fill" : "key")
                    .font(.system(size: keySize))
                    .padding()
                
                Image(systemName: passCode.count >= 3 ? "key.fill" : "key")
                    .font(.system(size: keySize))
                    .padding()
                
                Image(systemName: passCode.count >= 4 ? "key.fill" : "key")
                    .font(.system(size: keySize))
                    .padding()
            }
            .padding()
        }
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder, isPad: isPad))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder, isPad: isPad))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder, isPad: isPad))
                }
            }
            
            HStack {
                Button(action: {
                    passCode += "0"
                }, label: {
                    Text("0")
                        .font(.title2)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder, isPad: isPad))
                
                Button(action: {
                    passCode = String(passCode.dropLast())
                }, label: {
                    Image(systemName: "delete.left")
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder, isPad: isPad))
            }
        }
    }
}
