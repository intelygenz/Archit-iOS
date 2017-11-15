//  BaseNavigationController.swift
//  Created by Alex Rupérez on 6/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

class BaseNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? true
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return visibleViewController
    }

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return visibleViewController
    }

}
