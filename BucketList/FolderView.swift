//
//  FolderView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData

struct FolderView: View {
    
    @State var isShowListView = false
    @State var isShowFolderAdd = false
    
    var body: some View {
        VStack {
            NavigationStack{
                ZStack(alignment: .bottomTrailing) {
                    
                    folderArea
                    
                    
                    floatingButton
                        
                        }
                .toolbar{
                    ToolbarItemGroup(placement: .bottomBar) {
                        
                        bottomArea
                    }
                    
                    
                        }
                    }
            .navigationBarBackButtonHidden(true)
                }
             }
        }

#Preview {
    FolderView()
}

extension FolderView {
    
    
    private var folderArea: some View {
        ScrollView{
            Button(action: {
                isShowListView.toggle()
            }, label: {
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
                            .foregroundColor(.black)
                        , alignment: .top
                    )
                    
            })
            .navigationDestination(isPresented: $isShowListView, destination: {
                ListView()
            })
            
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
        Button(action: {
            isShowFolderAdd.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.black)
                .font(.largeTitle)
                .padding()
        })
        .sheet(isPresented: $isShowFolderAdd){
            
            AddFolderView()

                    
            }
    }
    
    private var bottomArea: some View {
        HStack(spacing:90) {
            
            Image(systemName: "folder")
                .font(.title2)
            
            Image(systemName: "gearshape")
                .font(.title2)
            
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
        }
        
    }
    
}
