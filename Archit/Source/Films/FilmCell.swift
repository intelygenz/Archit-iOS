//  FilmCell.swift
//  Created by Diego Manuel Molina Canedo on 11/12/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit

class FilmCell: UITableViewCell {

    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func inflate(imageUrl: URL?, titleText: String?, year: String?) {
        self.posterImageView?.kf.setImage(with: imageUrl, completionHandler: { (image, error, cache, url) in
            if image != nil {
                self.layoutSubviews()
            }
        })
        self.titleLabel.text = titleText
        self.yearLabel.text = year
    }

}
