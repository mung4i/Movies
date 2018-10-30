//
//  MovieTableViewCell.swift
//  Movies
//
//  Created by Martin Mungai on 30/10/2018.
//  Copyright © 2018 Martin Mungai. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func setImage(image: UIImage) {
        self.logo.image = image
    }

}
