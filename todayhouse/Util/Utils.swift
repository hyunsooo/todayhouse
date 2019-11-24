//
//  Utils.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(url: URL) {
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 0
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let data = data, let _ = response, error == nil else {
                if let error = error { NSLog(error.localizedDescription) }
                return
            }
            DispatchQueue.main.async { self.image = UIImage(data: data) }
        }.resume()
    }
}

extension UIViewController {
    func alert(message : String) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alertController.addAction( UIAlertAction(title: "확인", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }) )
        self.present(alertController, animated: false, completion: nil)
    }
}

extension UILabel {
    func calculateLineCount() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: "Apple SD Gothic Neo", size: 15)!], context: nil)
        let lineCount = Int(ceil(textSize.height/charSize))
        return lineCount
    }
}

class Utils {
    static func getTextSize(text: String) -> CGSize {
        let label = UILabel()
        label.font = UIFont(name: "Apple SD Gothic Neo", size: 15)
        label.text = text
        let maxSize = CGSize(width: CGFloat(Float.infinity), height: label.frame.size.height)
        let ntext = text as NSString
        let textSize = ntext.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: "Apple SD Gothic Neo", size: 15)!], context: nil)
        return textSize.size
    }
}
