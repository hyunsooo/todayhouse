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
        btn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return btn
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = .white
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tv
    }()
    
    override init() {
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterMenuCell.self, forCellReuseIdentifier: FilterMenuCell.identifier)
        tableView.register(FilterMenuHeaderView.self, forHeaderFooterViewReuseIdentifier: FilterMenuHeaderView.identifier)
        tableView.allowsMultipleSelection = true
    }
    
    func showFilter(_ category: Category, selectedFilters: [Filter]) {
        
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
            
            tableView.reloadData()
            if !selectedFilters.isEmpty {
                for i in 0..<category.value.count {
                    let filter = category.value[i]
                    if selectedFilters.contains(where: {$0.value == filter.value}) {
                        DispatchQueue.main.async {
                            self.tableView.selectRow(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: .none)
                        }
                    }
                }
            }
            
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
        delegate?.reload()
    }
}

extension FilterMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterMenuCell.identifier, for: indexPath) as? FilterMenuCell else { return FilterMenuCell(style: .default, reuseIdentifier: FilterMenuCell.identifier) }
        cell.menuNameLabel.text = category?.value[indexPath.row].title
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9843137255, blue: 1, alpha: 1)
        cell.selectedBackgroundView = selectedBackgroundView
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
        guard let rows = tableView.indexPathsForSelectedRows, let category = category else { return }
        rows.forEach {
            tableView.deselectRow(at: $0, animated: false)
            delegate?.initializeFilter(type: category.key)
        }
    }
}
