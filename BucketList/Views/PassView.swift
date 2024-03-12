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
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var passCode = ""
    @State var selectedFolder: FolderModel
    @Binding var isShowPassInputPage: Bool
    let UINFGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack {
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
                        .onChange(of: passCode) {
                                if passCode.count == 4 {
                                    if passCode == selectedFolder.unwrappedfolderPassword {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                            isShowPassInputPage = false
                                            passCode = ""
                                        }
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
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
    


extension PassView {
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder))
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
                    .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder))
                }
            }
            
            HStack {
                Button(action: {
                    passCode += "0"
                }, label: {
                    Text("0")
                        .font(.title2)
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder))
                
                Button(action: {
                    passCode = String(passCode.dropLast())
                }, label: {
                    Image(systemName: "delete.left")
                })
                .buttonStyle(CapsuleButtonStyle(selectedFolder: selectedFolder))
            }
        }
    }
}
