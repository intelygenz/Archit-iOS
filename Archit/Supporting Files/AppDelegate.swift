//  AppDelegate.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, AppDelegateProtocol {

    lazy var appManager: AppManagerProtocol = AppManager.shared
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return appManager.didFinishLaunching(launchOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        appManager.willResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appManager.didEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        appManager.willEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appManager.didBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        appManager.willTerminate()
    }


}

