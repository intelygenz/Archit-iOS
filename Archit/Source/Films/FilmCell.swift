//
//  FilmCell.swift
//  Archit
//
//  Created by Diego Manuel Molina Canedo on 11/12/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import UIKit

class FilmCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
