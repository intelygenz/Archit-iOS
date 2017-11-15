//  FilmDetailViewController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit
import Kingfisher
import SafariServices

class FilmDetailViewController: BaseViewController<FilmDetailController> {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var plotTextView: UITextView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controller = FilmDetailController(self)
    }

    func reloadData() {
        loadViewIfNeeded()
        title = controller.film?.title
        titleLabel.text = controller.film?.title
        yearLabel.text = controller.film?.year
        plotTextView.text = controller.film?.plot
        posterImageView.kf.setImage(with: controller.film?.poster)
        navigationItem.rightBarButtonItem = controller.film?.website != nil ? UIBarButtonItem(title: "Website", style: .done, target: self, action: #selector(websiteAction(_:))) : nil
    }

    @objc func websiteAction(_ sender: Any) {
        guard let website = controller.film?.website else {
            return
        }
        present(SFSafariViewController(url: website), animated: true)
    }

}
