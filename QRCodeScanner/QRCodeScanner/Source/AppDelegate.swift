//
//  AppDelegate.swift
//  QRCodeScanner
//
//  Created by Lukasz Marcin Margielewski on 20/09/2017.
//  Copyright © 2017 Unwire ApS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        self.window?.rootViewController = QRScannerViewController()//UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
        return true
    }
}
