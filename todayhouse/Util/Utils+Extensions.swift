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
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!],
                                         context: nil)
        let lineCount = Int(ceil(textSize.height/charSize))
        return lineCount
    }
    
    func addTrailing(with moreText: String, moreTextColor: UIColor) {

        let readMoreText: String = moreText
        if  visibleLength == 0 { return }
        let lengthForVisibleString: Int = visibleLength

        if let myText = self.text {

            let mutableString: String = myText
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            print(safeTrimmedString)
            if safeTrimmedString.count <= readMoreLength { return }

            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "")
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        } else {
            print("💋")
        }
    }

    var visibleLength: Int {
        var index: Int = 0
        var prev: Int = 0
        let text = (self.text ?? "") as NSString
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: self.font!]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let originalTextSize = attributedText.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                                                 options: .usesLineFragmentOrigin,
                                                 context: nil).size
        
        if originalTextSize.height > frame.height {
            while index != NSNotFound
               && index < self.text!.count
               && text.substring(to: index)
                    .boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                             options: .usesLineFragmentOrigin,
                             attributes: [NSAttributedString.Key.font: self.font!],
                             context: nil).size.height <= (font.lineHeight * CGFloat(numberOfLines)) {
                prev = index
                index += 1
                if lineBreakMode == .byCharWrapping {
                    index += 1
                } else {
                    index = text.rangeOfCharacter(from: .whitespacesAndNewlines,
                                                  options: [],
                                                  range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            }
            return prev
        }
        
        return self.text!.count
    }

}



class Utils {
    static func getTextSize(text: String, font: UIFont) -> CGSize {
        let label = UILabel()
        label.font = font
        label.text = text
        let maxSize = CGSize(width: CGFloat(Float.infinity), height: label.frame.size.height)
        let ntext = text as NSString
        let textSize = ntext.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return textSize.size
    }
}
