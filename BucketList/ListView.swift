//
//  ListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/08.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        VStack{
            NavigationStack {
                List {
                    ForEach(1..<21){ number in
                        Text("やりたいこと \(number)")
                            .listRowSeparatorTint(.blue, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.gray, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        toolBar
                    }
                
                }
            }
            
            
            Spacer()
            
            bottomArea
        }
  }
}


#Preview {
    ListView()
}

extension ListView {
    
    private var toolBar : some View {
        VStack{
            Text("2023年の自分磨きやりたいこと100")
                .font(.headline)
            HStack{
                Text("2023/01/01~2023/12/31")
                    .font(.subheadline)
                    .padding(.trailing)
                Text("達成率 20/100")
                    .font(.subheadline)
            }
        }
    }
    
    private var bottomArea: some View {
        HStack(spacing:100) {
            Image(systemName: "folder")
                .font(.largeTitle)
            
            Image(systemName: "gearshape")
                .font(.largeTitle)
            
            Image(systemName: "square.and.arrow.up")
                .font(.largeTitle)
            
        }
        .padding()
        .background(.white)
    }
}
