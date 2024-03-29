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
    var zDescriptionLabel: UILabel?
    
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
        
        startingFrame = imageView.frame
        imageView.isHidden = true
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.layer.masksToBounds = true
//        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomingImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        zoomingImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch)))
        
        if let window = UIApplication.shared.windows.first {
            backView = UIView(frame: window.frame)
            backView?.backgroundColor = .black
            backView?.alpha = 0
            
            zDescriptionLabel = UILabel()
            zDescriptionLabel?.numberOfLines = 5
            zDescriptionLabel?.text = model?.description
            zDescriptionLabel?.translatesAutoresizingMaskIntoConstraints = false
            zDescriptionLabel?.alpha = 0
            zDescriptionLabel?.textColor = .white
            
            window.addSubview(backView!)
            window.addSubview(zoomingImageView)
            window.addSubview(zDescriptionLabel!)
            
            zDescriptionLabel?.topAnchor.constraint(equalTo: zoomingImageView.bottomAnchor, constant: 10).isActive = true
            zDescriptionLabel?.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 16).isActive = true
            zDescriptionLabel?.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -16).isActive = true
            zDescriptionLabel?.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.backView?.alpha = 1
                self.zDescriptionLabel?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: self.startingFrame!.height )
                zoomingImageView.center = window.center
            })
        }
    }
    
    @objc func zoomOut(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let zoomingImageView = gestureRecognizer.view else { return }
        _zoomOut(zoomingImageView)
    }
    
    private func _zoomOut(_ zoomingImageView: UIView) {
        self.zDescriptionLabel?.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.backView?.alpha = 0
            self.imageView.alpha = 1
            zoomingImageView.frame = self.startingFrame!
        }) { (completed) in
            if completed {
                zoomingImageView.removeFromSuperview()
                self.imageView.isHidden = false
                self.backView = nil
                self.zDescriptionLabel = nil
            }
        }
    }
    
    @objc func pinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let zoomingImageView = gestureRecognizer.view else { return }
        let MINIMUM_SCALE: CGFloat = 1.0
        let MAXIMUM_SCALE: CGFloat = 4.0
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .changed {
            let currentScale = zoomingImageView.frame.size.width / zoomingImageView.bounds.size.width
            var newScale = currentScale * gestureRecognizer.scale

            if newScale < MINIMUM_SCALE { newScale = MINIMUM_SCALE }
            if newScale > MAXIMUM_SCALE { newScale = MAXIMUM_SCALE }

            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            zoomingImageView.transform = transform
            gestureRecognizer.scale = 1
            
            if newScale == MINIMUM_SCALE {
                self.zDescriptionLabel?.alpha = 1
            } else {
                self.zDescriptionLabel?.alpha = 0
            }
        }
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let zoomingImageView = gestureRecognizer.view else { return }
        let transition = gestureRecognizer.translation(in: zoomingImageView)
        
        let cX = zoomingImageView.center.x + transition.x
        let cY = zoomingImageView.center.y + transition.y
        zoomingImageView.center = CGPoint(x: cX, y: cY)
        gestureRecognizer.setTranslation(.zero, in: zoomingImageView)
        
        
        let velocity = gestureRecognizer.velocity(in: zoomingImageView)
        let standard: CGFloat = 400
        let pureVelocity: CGFloat = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
        let rate: CGFloat = pureVelocity / standard
        
        switch gestureRecognizer.state {
        case .began:
            self.zDescriptionLabel?.alpha = 0
        case .changed:
            // backView의 alpha 값을 조정하기 위해서 window의 중앙값 기준으로 거리 r을 잼 (피타고라스의 법칙)
            // 그 거리가 멀어질수록 alpha값을 내림.
            if let window = UIApplication.shared.windows.first {
                let centerX = window.center.x
                let centerY = window.center.y
                
                let distance = sqrt(pow(centerX - zoomingImageView.center.x, 2) + pow(centerY - zoomingImageView.center.y, 2)) / 5.0
                var alpha = (100.0 - distance) / 100.0
                alpha = alpha > 0 ? alpha : 0
                self.backView?.alpha = alpha
            }
        case .ended:
            if rate > 1 {
                _zoomOut(zoomingImageView)
            } else {
                if let window = UIApplication.shared.windows.first {
                     UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                                           self.backView?.alpha = 1
                                           self.zDescriptionLabel?.alpha = 1
                                           zoomingImageView.center = window.center
                                       })
                }
            }
        @unknown case _: break
        }
        
//        if gestureRecognizer.state == .ended {
//            if rate > 1 {
//                _zoomOut(zoomingImageView)
//            } else {
//                if let window = UIApplication.shared.windows.first {
//                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
//                        self.backView?.alpha = 1
//                        self.zDescriptionLabel?.alpha = 1
//                        zoomingImageView.center = window.center
//                    })
//                }
//            }
//        } else if gestureRecognizer.state == .changed {
//            if let window = UIApplication.shared.windows.first {
//                let centerX = window.center.x
//                let centerY = window.center.y
//
//                let distance = sqrt(pow(centerX - zoomingImageView.center.x, 2) + pow(centerY - zoomingImageView.center.y, 2)) / 5.0
//                var alpha = (100.0 - distance)/100.0
//                alpha = alpha > 0 ? alpha : 0
//                self.backView?.alpha = alpha
//            }
//        } else if gestureRecognizer.state == .began {
//            self.zDescriptionLabel?.alpha = 0
//        }
        
    }
}
