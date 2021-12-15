//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = .systemBlue
        UINavigationBar.appearance().tintColor = .white
        return true
    }
}
