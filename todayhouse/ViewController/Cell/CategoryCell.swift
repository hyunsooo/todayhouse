//
//  CategoryCell.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    static let identifier = "kCategoryCell"
    
    @IBOutlet var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
    }

}
