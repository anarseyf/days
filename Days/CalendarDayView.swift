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

class CalendarCellView: UIView {

    var background: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) { return }

        let frame = CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        let background = UIView(frame: frame)
        background.backgroundColor = .white
        self.addSubview(background)
        self.background = background
    }
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
            background?.backgroundColor = UIColor(named: "linkColor")

            let label = UILabel(frame: self.bounds)
            label.text = String(weekday)
            label.textColor = .white
            label.textAlignment = .center
            self.addSubview(label)
        }
    }
}

class CalendarDayView: CalendarCellView {

    var model: CalendarDayModel?

    init(model: CalendarDayModel?, frame: CGRect) {
        self.model = model
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) { return }

        if let model = model {
            background?.backgroundColor = .lightGray

            let label = UILabel(frame: self.bounds)
            label.text = String(model.dayOfMonth)
            label.textColor = .white
            label.textAlignment = .center
            self.addSubview(label)
        }
    }
}
