//  BaseController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

protocol BaseController {

    associatedtype ViewControllerClass: AnyObject

    weak var viewController: ViewControllerClass? { get }

    init(_ viewController: ViewControllerClass)

    func load()

    func unload()

    func memoryWarning()

    func willAppear(_ animated: Bool)

    func didAppear(_ animated: Bool)

    func willDisappear(_ animated: Bool)

    func didDisappear(_ animated: Bool)

    func prepareSegue(identifier: String?, destination: AnyObject)

}

extension BaseController {

    func load() {}

    func unload() {}

    func memoryWarning() {}

    func willAppear(_ animated: Bool) {}

    func didAppear(_ animated: Bool) {}

    func willDisappear(_ animated: Bool) {}

    func didDisappear(_ animated: Bool) {}

    func prepareSegue(identifier: String?, destination: AnyObject) {}

}

