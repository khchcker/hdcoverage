//
//  AppDelegate.swift
//  HDCoverageDemo
//
//  Created by denglibing on 2021/10/24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let infoDictionary =  Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary[ "CFBundleDisplayName" ]  //程序名称
        let majorVersion = infoDictionary[ "CFBundleShortVersionString" ] //主程序版本号
        let timezone = TimeZone.init(identifier: "Asia/Beijing")
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "MMddHHmmss"
        let name = "\(String(describing: appDisplayName))" + "_ios_" + "\(majorVersion!)".replacingOccurrences(of: ".", with: "_") + "_v" + formatter.string(from: Date.init())
        HDCoverageTools.shared.registerCoverage(moduleName: name)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

