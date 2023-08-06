//
//  BoardTableCellViewModel.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/05.
//

import Foundation
import UIKit

class BoardTableCellViewModel {
    
    // MARK: - Properties
    @Published var post: Post
    var searchString: String?
    
    init(post: Post, searchString: String? = nil) {
        self.post = post
        self.searchString = searchString
    }
    
    var timeStamp: String {
        guard let date: Date = post.createdDateTime.toDate() else { return "00:00" }
        let formatter = DateFormatter()
        
        Date().isSameDay(date) ? (formatter.dateFormat = "h:m") : (formatter.dateFormat = "yy-MM-dd")
        return "•\(formatter.string(for: date) ?? "-1")•"
    }
    
    var isNewPost: Bool {
        guard let date: Date = post.createdDateTime.toDate() else { return false }
        return Date().isSameDay(date)
    }
    
    var isNoticePost: Bool {
        return post.postType == "notice" ? true : false
    }
    
    var isIncludeAttachments: Bool {
        
        return post.attachmentsCount > 0 ? true : false
    }
    
    var titleAttributedString: NSAttributedString {
        let attrStr = self.searchStringAttributedString(post.title)
        
        return attrStr
    }
    
    var writerAttributedString: NSAttributedString {
        let attrStr = self.searchStringAttributedString(post.writer.displayName)
        
        return attrStr
    }
    
    func searchStringAttributedString(_ string: String) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(string: string)
        let entireLength = string.count
        var range = NSRange(location: 0, length: entireLength)
        var rangeArr = [NSRange]()
        
        while range.location != NSNotFound {
            
            range = (attrStr.string as NSString).range(of: searchString ?? "", options: .caseInsensitive, range: range)
            rangeArr.append(range)

            if range.location != NSNotFound {
                range = NSRange(location: range.location + range.length,
                                length: string.count - (range.location + range.length))
                
            }
            
        }
        rangeArr.forEach { range in
            attrStr.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
            
        }
        return attrStr

    }
    
}
