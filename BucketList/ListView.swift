//
//  ListView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2023/12/08.
//

import SwiftUI
import CoreData

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ListModel.text, ascending: true)],
            animation: .default)
        private var ListModels: FetchedResults<ListModel>
    
    @State var isShowListAdd = false
    
    var body: some View {
        VStack{
            ZStack(alignment: .bottomTrailing){
                NavigationStack {
                    List {
                            ForEach(ListModels){ ListModel in
                                HStack {
                                    Text("ListModel")
                                        .listRowSeparatorTint(.blue, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                                    
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.gray, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: FolderView()) {
                                Image(systemName: "arrowshape.turn.up.backward")
                                    .foregroundColor(.black)
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            navigationArea
                        }
                    }
                }
                HStack{
                    
                    Image(systemName: "list.bullet.circle.fill")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                    
                    Button(action: {
                        isShowListAdd.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.black)
                            .font(.largeTitle)
                            .padding()
                    })
                    .sheet(isPresented: $isShowListAdd){
                        
                        AddListView(isShowListAdd: $isShowListAdd)
                            .presentationDetents([.medium, .fraction(0.5)])
                                
                        }
                    }
  
                }
                
                
            }
              bottomArea
  }
}


#Preview {
    ListView()
}

extension ListView {
    
    private var navigationArea : some View {
        
                
            VStack{
                Text("2023年の自分磨きやりたいこと100")
                    .font(.headline)
                HStack{
                    Text("2023/01/01~2023/12/31")
                        .font(.subheadline)
                        .padding(.trailing)
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
