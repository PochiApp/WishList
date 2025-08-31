//
//  Date_Extension.swift
//  WishList
//
//  Created by 嶺澤美帆 on 2025/08/31.
//

import Foundation

extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ja_JP")
        formatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd")
        return formatter.string(from: self)
    }
}
