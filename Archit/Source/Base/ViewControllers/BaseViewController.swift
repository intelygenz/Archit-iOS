//  BaseViewController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit
import Reusable

class BaseViewController<ControllerClass: BaseController>: UIViewController, StoryboardSceneBased {

    class var sceneStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    var controller: ControllerClass!

    override func viewDidLoad() {
        assert(controller != nil, "You must set a BaseController for \(type(of: self)) in init?(coder: NSCoder)")
        super.viewDidLoad()
        controller.load()
    }

    deinit {
        controller.unload()
        controller = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        controller.memoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller.willAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.didAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controller.willDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controller.didDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        controller.prepareSegue(identifier: segue.identifier, destination: segue.destination)
    }

    func showAlert(_ title: String?, message: String? = nil, buttons: [String] = ["OK"], handler: ((UIAlertAction) -> Void)? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        buttons.forEach { title in
            alertController.addAction(UIAlertAction(title: title, style: .cancel, handler: handler))
        }
        present(alertController, animated: animated, completion: completion)
    }

}

