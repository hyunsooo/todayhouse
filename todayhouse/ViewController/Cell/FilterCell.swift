//
//  FilterCell.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    static let identifier = "kFilterCell"
    
    @IBOutlet var filterNameLabel: UILabel!
    @IBOutlet var closeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 13
    }

}
