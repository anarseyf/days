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

    var didLayoutSubviews = false

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
        if !didLayoutSubviews {
            if let monthModel = model {

                let cellWidth = floor(view.frame.width / CGFloat(monthModel.matrix.first!.count))
                let cellHeight = floor(view.frame.height / CGFloat(monthModel.matrix.count + 1))

                let formatter = DateFormatter()
                formatter.dateFormat = "E"
                let weekdaysRow = monthModel.matrix[1].map { model in
                    return formatter.string(from: model!.date)
                }

                for (rowIndex, weekday) in weekdaysRow.enumerated() {
                    let origin = CGPoint(x: CGFloat(rowIndex) * cellWidth, y: 0.0)
                    let size = CGSize(width: cellWidth, height: cellHeight)
                    let headerView = CalendarHeaderView(weekday: weekday,
                                                        frame: CGRect(origin: origin, size: size))
                    view.addSubview(headerView)
                }

                for (rowIndex, row) in monthModel.matrix.enumerated() {
                    let originY = CGFloat(rowIndex + 1) * cellHeight
                    for (colIndex, dayModel) in row.enumerated() {
                        let originX = CGFloat(colIndex) * cellWidth
                        let origin = CGPoint(x: originX, y: originY)
                        let size = CGSize(width: cellWidth, height: cellHeight)
                        let dayView = CalendarDayView(model: dayModel,
                                                      frame: CGRect(origin: origin, size: size))
                        view.addSubview(dayView)
                    }
                }

                didLayoutSubviews = true
            }
        }
    }
}
