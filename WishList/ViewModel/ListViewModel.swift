//
//  ListViewModel.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/08/28.
//

import SwiftUI
import CoreData
import PhotosUI

class ListViewModel: ObservableObject {
    //List関連
    @Published var text = ""
    @Published var listNumber = 0
    @Published var category = ""
    @Published var folderDate = Date()
    @Published var achievement = false
    @Published var datas: [Data] = []
    @Published var image1: Data = Data.init()
    @Published var image2: Data = Data.init()
    @Published var miniMemo = ""
    @Published var images: [UIImage?] = []
    @Published var updateList: ListModel!
    
    init(listNumber: Int, folderDate: Date) {
        self.listNumber = listNumber
        self.folderDate = folderDate
    }
    
    init(update: ListModel) {
        self.updateList = update
        
        text = update.unwrappedText
        category = update.unwrappedCategory
        achievement = update.achievement
        image1 = update.unwrappedImage1
        image2 = update.unwrappedImage2
        miniMemo = update.unwrappedMiniMemo
    }
    
    //MARK: - Listの新規作成や編集関連メソッド
    
    //Listの新規作成及び編集
    func writeList (context: NSManagedObjectContext) {
        
        //updateListがnilではない場合、Listの編集処理
        if updateList != nil {
            updateList.text = text
            updateList.category = category
            updateList.achievement = achievement
            updateList.image1 = image1
            updateList.image2 = image2
            updateList.miniMemo = miniMemo
            
            try! context.save()
            
            return
        }
        
        //updateListがnilの場合、Listの新規作成処理
        let newListData = ListModel(context:context)
        newListData.text = text
        newListData.listNumber = Int16(listNumber)
        newListData.category = category
        newListData.folderDate = folderDate
        newListData.achievement = false
        newListData.image1 = image1
        newListData.image2 = image2
        newListData.miniMemo = miniMemo
        
        do {
            try context.save()
        }
        catch {
            print("新しいメモが作れません")
        }
    }
    
    //編集するListとその内容をセット
//    func editList (updateList: ListModel) {
//        self.updateList = updateList
//        
//        text = self.updateList.unwrappedText
//        category = self.updateList.unwrappedCategory
//        achievement = self.updateList.achievement
//        image1 = self.updateList.unwrappedImage1
//        image2 = self.updateList.unwrappedImage2
//        miniMemo = self.updateList.unwrappedMiniMemo
//    }
    
    //ViewModel内のList関連の変数を初期化
    func resetList () {
        updateList = nil
        
        text =  ""
        listNumber = 0
        category = ""
        folderDate = Date()
        achievement = false
        image1 = Data.init()
        image2 = Data.init()
        miniMemo = ""
        
        images = []
    }
    
    //MARK: - Listの画像処理関連メソッド
    func resetImages () {
        datas = []
        images = []
        image1 = Data.init()
        image2 = Data.init()
    }
    
    //PhotosPickerで取得した画像をData型に変換
    func convertDataimages (photos: [PhotosPickerItem]) async {
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            
            DispatchQueue.main.async {
                self.datas.append(data)
            }
        }
    }
    
    //Data型画像 → UIImage型画像に変換
    func convertUiimages () async {
        if !self.images.isEmpty {
            DispatchQueue.main.async {
                self.images.removeAll()
            }
        }
        
        DispatchQueue.main.async {
            guard let uiimage1 = UIImage(data: self.image1) else { print("uiimage失敗1"); return }
            self.images.append(uiimage1)
            
            guard let uiimage2 = UIImage(data: self.image2) else { print("uiimage失敗2");return }
            self.images.append(uiimage2)
        }
    }
}
