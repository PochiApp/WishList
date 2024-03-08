//
//  PassView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/07.
//

import SwiftUI

struct PassView: View {
    
    @State var passCode = ""
//    @State var themeColor: String
    
    var body: some View {
        VStack {
            Text("\(passCode)")
                .font(.title2)
            
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



