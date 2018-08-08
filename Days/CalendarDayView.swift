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

        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 1.0

        let frame = CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        let square = UIView(frame: frame)
        square.backgroundColor = (model == nil ? .white : .darkGray)
        self.addSubview(square)

        if let model = model {
            let label = UILabel(frame: frame)
            label.text = String(model.dayOfMonth)
            label.textColor = .white
            label.textAlignment = .center
            self.addSubview(label)
        }
    }
}
