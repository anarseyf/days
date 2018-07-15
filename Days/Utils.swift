//
//  Utils.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class Utils {
    static let secondsPerDay = 60 * 60 * 24
    static let startDateBracket = Double(secondsPerDay) * 366.0
    static let minDays = 0
    static let maxDays = 366

    static let shared = Utils()

    let dateOnlyFormatter = DateFormatter()
    let timeOnlyFormatter = DateFormatter()
    let dateTimeFormatter = DateFormatter()
    let intervalFormatter = DateComponentsFormatter()

    private init() {
        
        dateOnlyFormatter.dateStyle = .medium
        dateOnlyFormatter.timeStyle = .none
        timeOnlyFormatter.dateStyle = .none
        timeOnlyFormatter.timeStyle = .medium
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .medium

        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        intervalFormatter.unitsStyle = .abbreviated
    }

    static func daysString(from days: Int) -> String {
        return (days == 1 ? "\(days) day" : "\(days) days")
    }
}
