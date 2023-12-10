//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI

struct FolderView: View {
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                
                folderArea
                
                
                floatingButton
                    
            }
                bottomArea
            
                }
             }
        }

#Preview {
    FolderView()
}

extension FolderView {
    
    
    private var folderArea: some View {
        ScrollView{
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
                .overlay(
                    VStack(alignment: .center){
                        Text("2023/01/01 ~ 2023/12/31")
                            .font(.system(size: 16))
                            .padding(.top)
                        Text("2023年の自分磨きやりたいこと100")
                            .lineLimit(2)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top)
                        Text("達成率：20/100")
                            .padding(.top)
                            .font(.system(size: 15))
                    }
                    
                    , alignment: .top
                )
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
            Rectangle()
                .fill(Color.gray)
                .frame(width: 300, height: 150)
        }
    }
    
    private var floatingButton: some View {
        Image(systemName: "plus.circle.fill")
            .foregroundColor(.black)
            .font(.largeTitle)
            .padding()
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
