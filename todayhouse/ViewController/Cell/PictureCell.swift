//
//  PictureCell.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    static let identifier = "kPictureCell"

    let imageView = UIImageView()
    let moreView = UIView()
    let moreLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
        
        moreView.frame = self.bounds
        moreView.backgroundColor = .black
        moreView.alpha = 0.5
        self.addSubview(moreView)
        
        moreLabel.textColor = .white
        moreLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        moreView.addSubview(moreLabel)
        
        setConstraintsOfMoreView()
    }
    
    func setConstraintsOfMoreView() {
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        moreLabel.centerXAnchor.constraint(equalTo: moreView.centerXAnchor).isActive = true
        moreLabel.centerYAnchor.constraint(equalTo: moreView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        moreView.alpha = 0
    }
}

extension PictureCell {
    func setImage(_ urls: String) {
        if let url = URL(string: urls) {
            imageView.setImage(url: url)
        }
    }
    
    func showMoreView(count: Int) {
        moreView.alpha = 0.5
        moreLabel.text = "+\(count)"
    }
}

