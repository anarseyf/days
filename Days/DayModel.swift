//
//  DayModel.swift
//  Days
//
//  Created by Anar Seyf on 8/10/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

struct DayModel : CustomStringConvertible {
    let date: Date
    let weekday: Int
    let dayOfMonth: Int
    var isToday: Bool
    var isSelected: Bool

    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd (E)"
        return formatter.string(from: date)
    }

    var isOnWeekend: Bool {
        return weekday == 1 || weekday == 7
    }
}
