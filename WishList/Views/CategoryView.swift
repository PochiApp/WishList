//
//  CategoryView.swift
//  BucketList
//
//  Created by 嶺澤美帆 on 2024/02/04.
//

import CoreData
import SwiftUI

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(
        entity: CategoryEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CategoryEntity.categoryAddDate,
                ascending: true
            )
        ],
        animation: .default
    )
    private var categorys: FetchedResults<CategoryEntity>
    @StateObject var categoryViewModel = CategoryViewModel()
    @State var isShowCategoryAdd = false
    @State var isEditMode = false

    var body: some View {
        NavigationView {
            ZStack {
                //Categoryが未設定のに表示するView
                if categorys.isEmpty {
                    emptyCategoryView
                }
                //フェッチしたCategoryの表示 deleteボタンは横スワイプで表示
                List {
                    ForEach(categorys) { category in
                        if !isEditMode {
                            Text("\(category.unwrappedCategoryName)")
                                .font(.title3)
                        } else {
                            categoryTextField(category)
                        }
                    }
                    .onDelete(perform: deleteCategory)
                }
                .listStyle(.grouped)
                .background(Color.gray.opacity(0.1))
                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        if !isEditMode {
                            floatingButton
                        }
                    }
                    .padding(
                        EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 30)
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationTitle
            }
            ToolbarItem(placement: .topBarLeading) {
                if !isEditMode {
                    backButton
                } else {
                    cancelButton
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if !isEditMode {
                    editButton
                } else {
                    confirmButton
                }
            }
        }
        .font(.title3)
        .sheet(isPresented: $isShowCategoryAdd) {

            AddCategoryView(
                categoryViewModel: categoryViewModel,
                isShowCategoryAdd: $isShowCategoryAdd
            )
            .presentationDetents([.medium])
        }
    }

    private func deleteCategory(offSets: IndexSet) {
        offSets.map { categorys[$0] }.forEach(context.delete)

        do {
            try context.save()
        } catch {
            print("削除失敗")
        }
    }
}

//MARK: - extension
extension CategoryView {
    private var floatingButton: some View {
        Button(
            action: {
                isShowCategoryAdd.toggle()
            },
            label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black)
                    .shadow(color: .gray.opacity(0.4), radius: 3, x: 2, y: 2)
                    .font(.system(size: 40))
                    .padding()
            }
        )
    }

    private func categoryTextField(_ category: CategoryEntity) -> some View {
        TextField(
            "",
            text: Binding(
                get: { category.unwrappedCategoryName },
                set: { newValue in
                    category.categoryName = newValue
                }
            )
        )
    }

    private var emptyCategoryView: some View {
        VStack(alignment: .center) {
            Image(systemName: "books.vertical")
                .font(.system(size: 100))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.bottom)

            Text("カテゴリーを追加して、リストを分類しましょう")
                .font(.caption)
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }

    //モーダル上部のタイトル名
    private var navigationTitle: some View {
        Text("カテゴリー一覧")
            .font(.title3)
            .foregroundColor(Color("originalBlack"))
    }

    private var backButton: some View {
        Button(
            action: {
                presentationMode.wrappedValue.dismiss()
            },
            label: {
                Image(systemName: "arrowshape.turn.up.backward")
                    .foregroundColor(Color("originalBlack"))
            }
        )
    }

    private var cancelButton: some View {
        Button(
            action: {
                categoryViewModel.rollbackCategory(context: context)
                isEditMode = false
            },
            label: {
                Text("キャンセル")
                    .font(.subheadline)
                    .foregroundColor(Color("originalBlack"))
            }
        )
    }

    private var editButton: some View {
        Button(
            action: {
                isEditMode = true
            },
            label: {
                Text("編集")
                    .foregroundColor(Color("originalBlack"))
            }
        )
    }

    private var confirmButton: some View {
        Button(
            action: {
                categoryViewModel.saveCategory(context: context)
                isEditMode = false
            },
            label: {
                Text("保存")
                    .foregroundColor(Color("originalBlack"))
            }
        )
    }
}
