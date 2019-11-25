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
    
    var type: FilterType?
    var filter: Filter?
    weak var delegate : ListViewControllerDelegate?
    
    @IBOutlet var filterNameLabel: UILabel!
    @IBOutlet var closeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 13
        
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
}

extension FilterCell {
    @objc func close() {
        guard let filter = filter, let type = type else { return }
        delegate?.deselectFilter(filter: filter, type: type)
        delegate?.reload()
    }
}
