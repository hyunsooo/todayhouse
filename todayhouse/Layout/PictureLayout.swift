//
//  PictureLayout.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/23.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

enum LayoutStyle {
    case full
    case double
    case triple
    case quarter
    case more
}

class PictureLayout: UICollectionViewLayout {
    
    var contentBounds = CGRect.zero
    private var cache = [UICollectionViewLayoutAttributes]()
    
   
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        cache.removeAll()
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard numberOfItems != 0 else { return }
        
        var style: LayoutStyle = .full
        
        switch numberOfItems {
        case 1: style = .full
        case 2: style = .double
        case 3: style = .triple
        case 4: style = .quarter
        default: style = .more
        }
        
        var pictureFrames = [CGRect]()
        
        switch style {
        case .full :
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 291.0)
            contentBounds = frame
            pictureFrames = [frame]
        case .double :
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width / 2) - 1.5)
            contentBounds = frame
            let slices = frame.dividedIntegral(fraction: 0.5, from: .minXEdge)
            pictureFrames = [slices.first, slices.second]
        case .triple :
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
            contentBounds = frame
            let slices = frame.dividedIntegral(fraction: 0.5, from: .minYEdge)
            let bottomSlices = slices.second.dividedIntegral(fraction: 0.5, from: .minXEdge)
            pictureFrames = [slices.first, bottomSlices.first, bottomSlices.second]
        case .quarter :
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
            contentBounds = frame
            let slices = frame.dividedIntegral(fraction: 0.5, from: .minYEdge)
            let topSlices = slices.first.dividedIntegral(fraction: 0.5, from: .minXEdge)
            let bottomSlices = slices.second.dividedIntegral(fraction: 0.5, from: .minXEdge)
            pictureFrames = [topSlices.first,topSlices.second, bottomSlices.first, bottomSlices.second]
        case .more :
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
            contentBounds = frame
            let slices = frame.dividedIntegral(fraction: 2/3, from: .minYEdge)
            let bottomSlices = slices.second.dividedIntegral(fraction: 1/3, from: .minXEdge)
            let bottomSecondSlices = bottomSlices.second.dividedIntegral(fraction: 0.5, from: .minXEdge)
            pictureFrames = [slices.first, bottomSlices.first, bottomSecondSlices.first, bottomSecondSlices.second]
        }
            
        for index in 0..<pictureFrames.count {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = pictureFrames[index]
            
            cache.append(attributes)
//            contentBounds = contentBounds.union(pictureFrames[index])
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

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.slice.size.width -= 1.5
            slices.remainder.origin.x += 3.0
            slices.remainder.size.width -= 1.5
        case .minYEdge, .maxYEdge:
            slices.slice.size.height -= 1.5
            slices.remainder.origin.y += 3.0
            slices.remainder.size.height -= 1.5
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}
