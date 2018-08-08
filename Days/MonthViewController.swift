//
//  MonthViewController.swift
//  Days
//
//  Created by Anar Seyf on 8/6/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

struct CalendarMonthModel : CustomStringConvertible {
    let matrix: [[CalendarDayModel?]]
    let startDate: Date

    var description: String {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy\n"
        var result = formatter.string(from: startDate)

        for row in matrix {
            for (index, day) in row.enumerated() {
                result += (day?.description ?? "--      ") + (index == row.count - 1 ? "" : ", ")
            }
            result += "\n"
        }
        return result
    }
}

class MonthViewController: UIViewController {

    var startDate: Date? {
        didSet {
            if let date = startDate {
                model = Utils.calendarModel(forStartDate: date)
                print(model)
            }
        }
    }

    var model: CalendarMonthModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cellWidth = floor(view.frame.width / 7)

        if let monthModel = model {
            for (rowIndex, row) in monthModel.matrix.enumerated() {
                let originY = CGFloat(rowIndex) * cellWidth
                for (colIndex, dayModel) in row.enumerated() {
                    let originX = CGFloat(colIndex) * cellWidth
                    let origin = CGPoint(x: originX, y: originY)
                    let size = CGSize(width: cellWidth, height: cellWidth)
                    let dayView = CalendarDayView(model: dayModel, frame: CGRect(origin: origin, size: size))
                    view.addSubview(dayView)
                }
            }
        }
    }
}
