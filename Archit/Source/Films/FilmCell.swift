//  FilmCell.swift
//  Created by Diego Manuel Molina Canedo on 11/12/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

class FilmCell: UITableViewCell {

    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var yearLabel: UILabel!

    public func configure(imageUrl: URL?, titleText: String?, year: String?) {
        self.posterImageView?.kf.setImage(with: imageUrl, completionHandler: { (image, error, cache, url) in
            if image != nil, error == nil {
                self.layoutSubviews()
            }
        })
        self.titleLabel.text = titleText
        self.yearLabel.text = year
    }

}
