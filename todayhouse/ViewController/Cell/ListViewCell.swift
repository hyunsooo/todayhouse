//
//  ListViewCell.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell {
    static let identifier = "kListViewCell"
        
    var imageUrls: [String] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded() // PictureLayout에서 컨텐트 사이즈가 책정됨.
            
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.removeConstraint(self.collectionView.constraints.filter { $0.identifier == "collectionViewHeightConstraint" }.first!)

            let heightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: self.collectionView.contentSize.height)

            heightConstraint.identifier = "collectionViewHeightConstraint"
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
        }
    }

    weak var delegate: ListViewControllerDelegate?
    var model: Model?
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: PictureCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageUrls = []
        descriptionLabel.text = ""
        model = nil
    }
}

extension ListViewCell {
    
    func update(_ data: Model) {
        self.model = data
        imageUrls = [data.imageUrl]
        self.descriptionLabel.text = data.description ?? ""
        if descriptionLabel.calculateLineCount() > 5 {
            self.descriptionLabel.text = "\(data.description ?? "") 더 보기"
        }
    }
}


extension ListViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCell.identifier, for: indexPath) as? PictureCell else { return PictureCell() }
        cell.setImage(imageUrls[indexPath.row])
        
        if imageUrls.count > 4 && indexPath.item == 3 {
            cell.showMoreView(count: imageUrls.count - 4)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = model {
            delegate?.showDetail(model)
        }
    }
}
