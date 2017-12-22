//  AppManager.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

public class AppManager: AppManagerProtocol {

    public static let shared: AppManagerProtocol = AppManager()
    fileprivate var splitViewController: UISplitViewController? {
        return application.appDelegate?.window??.rootViewController as? UISplitViewController
    }

    public func didFinishLaunching(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if let splitViewController = splitViewController,
            let navigationController = splitViewController.viewControllers.last as? BaseNavigationController {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .allVisible
        }

        return true
    }

    public func willResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    public func didEnterBackground() {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    public func willEnterForeground() {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    public func didBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    public func willTerminate() {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

public protocol AppDelegateProtocol: UIApplicationDelegate {

    var appManager: AppManagerProtocol { get set }
}

public protocol AppProtocol {

    weak var appDelegate: AppDelegateProtocol? { get }
}

extension UIApplication: AppProtocol {

    public weak var appDelegate: AppDelegateProtocol? { return delegate as? AppDelegateProtocol }
}

public protocol AppManagerProtocol {

    static var shared: AppManagerProtocol { get }
    var application: AppProtocol { get }

    func didFinishLaunching(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool

    func willResignActive()

    func didEnterBackground()

    func willEnterForeground()

    func didBecomeActive()

    func willTerminate()
}

public extension AppManagerProtocol {

    var application: AppProtocol { return UIApplication.shared }
}

extension AppManager: UISplitViewControllerDelegate {

    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navigationController = secondaryViewController as? BaseNavigationController else { return false }
        guard let filmViewController = navigationController.topViewController as? FilmDetailViewController else { return false }
        return filmViewController.controller.film.value == nil
    }

}
