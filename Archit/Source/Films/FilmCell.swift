//  FilmCell.swift
//  Created by Diego Manuel Molina Canedo on 11/12/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

class FilmCell: UITableViewCell {

    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var yearLabel: UILabel!

    public func configure(imageUrl: URL?, title: String?, year: String?) {
        posterImageView?.kf.setImage(with: imageUrl, completionHandler: { (image, error, cache, url) in
            if image != nil, error == nil {
                self.layoutSubviews()
            }
        })
        titleLabel.text = title
        yearLabel.text = year
    }

}
