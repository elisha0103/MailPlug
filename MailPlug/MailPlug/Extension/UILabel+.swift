//
//  UILabel+.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/06.
//

import UIKit

extension NSMutableAttributedString {
    func changeAllOccurrence(entireString: String, searchString: String) -> NSMutableAttributedString {
          let attrStr = NSMutableAttributedString(string: entireString)
          let entireLength = entireString.count
          var range = NSRange(location: 0, length: entireLength)
          var rangeArr = [NSRange]()
          
          while range.location != NSNotFound {
              
              range = (attrStr.string as NSString).range(of: searchString, options: .caseInsensitive, range: range)
              rangeArr.append(range)

              if range.location != NSNotFound {
                  range = NSRange(location: range.location + range.length,
                                  length: entireString.count - (range.location + range.length))
                  
              }
              
          }
          rangeArr.forEach { range in
              attrStr.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
              
          }
        self.append(attrStr)
          return self
      }

}

extension NSMutableAttributedString {

    var fontSize: CGFloat {
        return 14
    }
    var boldFont: UIFont {
        return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    var normalFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    func bold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func regular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func specialColor(string: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange
        ]
        
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func orangeHighlight(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func blackHighlight(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func underlined(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
