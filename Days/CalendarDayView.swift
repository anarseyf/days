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

class CalendarCellView: UIView {
    var background: UIView?
    let fontSize: CGFloat = 18.0
}

class CalendarHeaderView: CalendarCellView {
    var weekday: String?

    init(weekday: String, frame: CGRect) {
        self.weekday = weekday
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) { return }

        if let weekday = weekday {

            let label = UILabel(frame: self.bounds)
            label.text = String(weekday)
            label.textColor = UIColor(named: "calendarWeekdayNameColor")
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
            self.addSubview(label)
        }
    }
}

class CalendarDayView: CalendarCellView {

    var model: CalendarDayModel?
    let borderWidth: CGFloat = 3.0

    init(model: CalendarDayModel?, frame: CGRect) {
        self.model = model
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func addBackgroundIfNeeded() {
        guard let model = model else { return }
        if model.isToday || model.isSelected {
            let diameter = min(frame.size.width, frame.size.height)
            let origin = CGPoint(x: (frame.size.width - diameter)/2,
                                 y: (frame.size.height - diameter)/2)
            let size = CGSize(width: diameter, height: diameter)
            let background = UIView(frame: CGRect(origin: origin, size: size))
            background.layer.cornerRadius = diameter/2
            if model.isToday {
                background.layer.borderWidth = borderWidth
                background.layer.borderColor = UIColor(named: "calendarTodayColor")?.cgColor
            }
            if model.isSelected {
                background.backgroundColor = UIColor(named: "calendarSelectedDayColor")
            }
            addSubview(background)
            self.background = background
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) { return }
        guard let model = model else { return }

        addBackgroundIfNeeded()

        let label = UILabel(frame: self.bounds)
        label.text = String(model.dayOfMonth)
        if model.isSelected {
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
        else {
            label.textColor = UIColor(named: model.isOnWeekend ? "secondaryTextColor" : "mainTextColor")
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        label.textAlignment = .center
        self.addSubview(label)
    }
}
