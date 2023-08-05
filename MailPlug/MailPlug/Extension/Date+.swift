//
//  Date+.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/05.
//

import Foundation

extension String {
    func toDate() -> Date? { // "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        return dateFormatter.string(from: self)
    }
    
    func isSameDay(_ date: Date) -> Bool {
        let firstFomatter = DateFormatter()
        firstFomatter.locale = Locale(identifier: Locale.current.identifier)
        
        let secondFomatter = DateFormatter()
        secondFomatter.locale = Locale(identifier: Locale.current.identifier)
        
        firstFomatter.dateFormat = "yyyy-MM-dd"
        secondFomatter.dateFormat = "yyyy-MM-dd"
        return firstFomatter.string(from: date) == secondFomatter.string(from: Date())
       
    }
}
