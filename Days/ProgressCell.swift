//
//  ProgressCell.swift
//  Days
//
//  Created by Anar Seyf on 7/11/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class ProgressCell: UICollectionViewCell {

    var completed = 0 {
        didSet {
            label.text = "\(completed) bars"
        }
    }
    var isActive = false

    @IBOutlet weak var label: UILabel!
}
