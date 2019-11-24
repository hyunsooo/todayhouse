//
//  FilterLayout.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

protocol FilterLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, sizeForIndexPath indexPath: IndexPath) -> CGSize
}

class FilterLayout: UICollectionViewLayout {

    weak var delegate: FilterLayoutDelegate?
    var contentBounds = CGRect.zero
    private var cache = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        cache.removeAll()
        
        let count = collectionView.numberOfItems(inSection: 0)
        var xOffset = [CGFloat]()
        xOffset.append(16)
        
        for i in 0..<count {
            let indexPath = IndexPath(item: i, section: 0)
            let size = delegate?.collectionView(collectionView, sizeForIndexPath: indexPath) ?? .zero
            
            let frame = CGRect(x: xOffset[i], y: 0, width: size.width, height: size.height)
            let margin: CGFloat = 4.0
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            contentBounds = contentBounds.union(frame)
            
            cache.append(attributes)
            if i < count-1 {
                xOffset.append(xOffset.last! + size.width + margin)
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
       
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
}
