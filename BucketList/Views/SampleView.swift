//
//  SampleView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/03/12.
//

import SwiftUI

struct SampleView: View {
    @State var isShowSetPassPage = false
    @State var isShowUnlockPassPage = false
    @State var isShowFolderWrite = false
    @State var lockIsActive = true
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
            Text("a")
        .contextMenu(ContextMenu(menuItems: {
            
                
            
            Button(action: {
               
                isShowFolderWrite.toggle()
                
            }, label: {
                Text("編集")
            })
            .sheet(isPresented: $isShowFolderWrite) {
                
                kariView()
            }
            
            
     
        }))
       
        
        
    }
    }


#Preview {
    SampleView()
}
