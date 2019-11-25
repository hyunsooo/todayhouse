//
//  DetailViewController.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/25.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var model: Model?
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var startingFrame: CGRect?
    var backView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        if let model = model {
            self.descriptionLabel.text = model.description
            if let url = URL(string: model.imageUrl) {
                self.imageView.setImage(url: url)
            }
        }
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomIn)))
    }
}

extension DetailViewController {
    @objc func zoomIn(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let image = imageView.image else { return }
        
        startingFrame = imageView.frame
        imageView.isHidden = true
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = image
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.layer.masksToBounds = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomingImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        if let window = UIApplication.shared.windows.first {
            backView = UIView(frame: window.frame)
            backView?.backgroundColor = .black
            backView?.alpha = 0
            window.addSubview(backView!)
            window.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.backView?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: self.startingFrame!.height )
                zoomingImageView.center = window.center
            })
        }
    }
    
    @objc func zoomOut(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let zoomingImageView = gestureRecognizer.view else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.backView?.alpha = 0
            self.imageView.alpha = 1
            zoomingImageView.frame = self.startingFrame!
        }) { (completed) in
            if completed {
                zoomingImageView.removeFromSuperview()
                self.imageView.isHidden = false
            }
        }
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let transition = gestureRecognizer.translation(in: imageView)
        let cX = imageView.center.x + transition.x
        let cY = imageView.center.y + transition.y
        imageView.center = CGPoint(x: cX, y: cY)
    }
}
