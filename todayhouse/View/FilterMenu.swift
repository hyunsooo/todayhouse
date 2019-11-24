//
//  FilterMenu.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/25.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

protocol FilterMenuDelegate: class {
    func initialize()
}

class FilterMenu: NSObject {
    
    var category: Category?
    weak var delegate: ListViewControllerDelegate?
    
    let backView = UIView()
    let menuView = UIView()
    lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = #colorLiteral(red: 0, green: 0.7860242724, blue: 0.9603441358, alpha: 1)
        btn.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)!
        btn.setTitle("확인", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        return btn
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = .white
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tv
    }()
    
    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .white
        return cv
    }()
    
    override init() {
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterMenuCell.self, forCellReuseIdentifier: FilterMenuCell.identifier)
        tableView.register(FilterMenuHeaderView.self, forHeaderFooterViewReuseIdentifier: FilterMenuHeaderView.identifier)
        tableView.allowsMultipleSelection = true
    }
    
    func showFilter(_ category: Category) {
        
        self.category = category
        
        if let window = UIApplication.shared.windows.first {
            backView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
            menuView.backgroundColor = #colorLiteral(red: 0, green: 0.7860242724, blue: 0.9603441358, alpha: 1)
            
            window.addSubview(backView)
            window.addSubview(menuView)
            
            menuView.addSubview(tableView)
            menuView.addSubview(confirmButton)
            
            let height: CGFloat = 425
            let buttonHeight: CGFloat = 70
            let y = window.frame.height - height
            menuView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            tableView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: height - buttonHeight)
            confirmButton.frame = CGRect(x: 0, y: height - buttonHeight, width: window.frame.width, height: buttonHeight)
            backView.frame = window.frame
            backView.alpha = 0
            
            collectionView.reloadData()
            tableView.reloadData()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.backView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: y, width: self.menuView.frame.width, height: self.menuView.frame.height)
            })
            
        }
    }
    
    @objc func dismiss() {
       UIView.animate(withDuration: 0.5,
                      delay: 0,
                      usingSpringWithDamping: 1,
                      initialSpringVelocity: 1,
                      options: .curveEaseInOut, animations: {
                        self.backView.alpha = 0
                        if let window = UIApplication.shared.windows.first {
                            self.menuView.frame = CGRect(x: 0, y: window.frame.height, width: self.menuView.frame.width, height: self.menuView.frame.height)
                            
                        }
       })
    }
    
    @objc func confirm() {
        dismiss()
    }
}

extension FilterMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterMenuCell.identifier, for: indexPath) as? FilterMenuCell else { return FilterMenuCell(style: .default, reuseIdentifier: FilterMenuCell.identifier) }
        cell.menuNameLabel.text = category?.value[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = category else { return nil }
        let header = FilterMenuHeaderView()
        header.setTitle(category.key.rawValue)
        header.delegate = self
        header.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ListViewController - selectedFilters append & reload
        guard let category = category else { return }
        delegate?.selectFilter(filter: category.value[indexPath.row], type: category.key)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // ListViewController - selectedFilters remove & reload
        guard let category = category else { return }
        delegate?.deselectFilter(filter: category.value[indexPath.row], type: category.key)
    }
}

extension FilterMenu: FilterMenuDelegate {
    func initialize() {
        guard let rows = tableView.indexPathsForSelectedRows else { return }
        rows.forEach { tableView.deselectRow(at: $0, animated: false) }
    }
}
