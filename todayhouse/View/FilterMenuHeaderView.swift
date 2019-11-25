//
//  FilterMenuHeaderView.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/25.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class FilterMenuHeaderView: UITableViewHeaderFooterView {

    static let identifier = "kFilterMenuHeaderView"
    weak var delegate: FilterMenuDelegate?
    let titleLabel = UILabel()
    lazy var initializeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        btn.setTitleColor(#colorLiteral(red: 0, green: 0.7860242724, blue: 0.9603441358, alpha: 1), for: .normal)
        btn.setTitle("초기화", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(initialize), for: .touchUpInside)
        return btn
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        tintColor = .white
        
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        
        addSubview(titleLabel)
        addSubview(initializeButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        initializeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        initializeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    @objc func initialize() {
        delegate?.initialize()
    }

}
