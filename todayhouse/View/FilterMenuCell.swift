//
//  FilterMenuCell.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/25.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class FilterMenuCell: UITableViewCell {
    
    static let identifier = "kFilterMenuCell"
    
    let menuNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        menuNameLabel.translatesAutoresizingMaskIntoConstraints = false
        menuNameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        addSubview(menuNameLabel)
        menuNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        menuNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        menuNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 16).isActive = true
    }
    
//    override var isSelected: Bool {
//        didSet {
//            backgroundColor = isSelected ? #colorLiteral(red: 0.937254902, green: 0.9843137255, blue: 1, alpha: 1) : .white
//            menuNameLabel.textColor = isSelected ? #colorLiteral(red: 0, green: 0.7860242724, blue: 0.9603441358, alpha: 1) : .black
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = selected ? #colorLiteral(red: 0.937254902, green: 0.9843137255, blue: 1, alpha: 1) : .white
        menuNameLabel.textColor = selected ? #colorLiteral(red: 0, green: 0.7860242724, blue: 0.9603441358, alpha: 1) : .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        menuNameLabel.text = ""
    }
}
