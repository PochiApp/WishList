//
//  PassView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/07.
//

import SwiftUI

struct PassView: View {
    
    @State var passCode = ""
    private let correctPassCode: String = "1234"
    @ObservedObject var bucketViewModel : BucketViewModel
    @State var selectedFolder: FolderModel
    @Binding var isShowPassInputPage: Bool
    
    var body: some View {
        VStack {
            HStack {
                
                Image(systemName: passCode.count >= 1 ? "key.fill" : "key")
                    .font(.title)
                    .padding()
                
                Image(systemName: passCode.count >= 2 ? "key.fill" : "key")
                    .font(.title)
                    .padding()
                
                Image(systemName: passCode.count >= 3 ? "key.fill" : "key")
                    .font(.title)
                    .padding()
                
                Image(systemName: passCode.count >= 4 ? "key.fill" : "key")
                    .font(.title)
                    .padding()
            }
            .padding()
            
            HStack {
                ForEach(1...3, id: \.self) { number in
                    Button(action: {
                        passCode += "\(number)"
                    }, label: {
                        Text("\(number)")
                            .font(.title2)
                    })
                    .buttonStyle(CapsuleButtonStyle())
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
                    .buttonStyle(CapsuleButtonStyle())
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
                    .buttonStyle(CapsuleButtonStyle())
                }
            }
            
            HStack {
                Button(action: {
                    passCode += "0"
                }, label: {
                    Text("0")
                        .font(.title2)
                })
                .buttonStyle(CapsuleButtonStyle())
            
                Button(action: {
                    passCode = String(passCode.dropLast())
                }, label: {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color("originalBlack"))
                })
                .buttonStyle(CapsuleButtonStyle())
            }
                    
                }
        .onChange(of: passCode) {
            if passCode.count == 4 {
                if passCode == selectedFolder.unwrappedfolderPassword {
                    isShowPassInputPage = false
                }
            }
        }
        }
    
    struct CapsuleButtonStyle: ButtonStyle {
        
//        @State var themeColor: String
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(8)
                .frame(width: 80, height: 80)
                .background(Color("originalPink"))
                .foregroundColor(Color("originalBlack"))
                .font(.body.bold())
                .clipShape(Capsule())
                .padding(8)
                
        }
    }
}

struct CustomPasscodeFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color("originalBlack"), lineWidth: 2)
                )
        
    }
}






