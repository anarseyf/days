//
//  CalendarDayView.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

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

    var model: DayModel? {
        didSet {
            setNeedsLayout()
        }
    }
    var label: UILabel?
    let borderWidth: CGFloat = 3.0

    init(model: DayModel?, frame: CGRect) {
        self.model = model
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        if label == nil {
            label = UILabel(frame: self.bounds)
            label!.textAlignment = .center
            self.addSubview(label!)
        }
        updateLabel()
        updateBackground()
    }

    private func updateLabel() {
        guard let model = model else { return }

        label?.text = String(model.dayOfMonth)
        if model.isSelected {
            label?.textColor = .white
            label?.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
        else {
            label?.textColor = UIColor(named: model.isOnWeekend ? "secondaryTextColor" : "mainTextColor")
            label?.font = UIFont.systemFont(ofSize: fontSize)
        }
    }

    private func updateBackground() {
        guard let model = model else { return }

        self.background?.removeFromSuperview()

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
            insertSubview(background, at: 0)
            self.background = background
        }
    }
}
