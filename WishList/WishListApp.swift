//
//  WishListApp.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2023/12/07.
//

import SwiftUI
import CoreData
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
}
@main
struct WishListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let persistence = PersistenceController.shared
        var body: some Scene {
            WindowGroup {
                FirstTabView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
        }
}
