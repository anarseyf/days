//
//  CalendarDayView.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

struct CalendarDayModel : CustomStringConvertible {
    let date: Date
    let weekday: Int
    let dayOfMonth: Int

    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd (E)"
        return formatter.string(from: date)
    }
}

class CalendarDayView: UIView {

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) { return }

        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 1.0
    }
}
