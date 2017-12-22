//  FilmDetailViewController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit
import Kingfisher
import SafariServices
import RxSwift

class FilmDetailViewController: BaseViewController<FilmDetailController> {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var plotTextView: UITextView!

    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controller = FilmDetailController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        controller.film.asObservable().bind { film in
            self.title = film?.title
            self.titleLabel.text = film?.title
            self.yearLabel.text = film?.year
            self.plotTextView.text = film?.plot
            self.posterImageView.kf.setImage(with: film?.poster)
            self.navigationItem.rightBarButtonItem = film?.website != nil ? UIBarButtonItem(title: "Website", style: .done, target: self, action: #selector(self.websiteAction(_:))) : nil
        }.disposed(by: disposeBag)
    }

    @objc func websiteAction(_ sender: Any) {
        guard let website = controller.film.value?.website else {
            return
        }
        present(SFSafariViewController(url: website), animated: true)
    }

}
