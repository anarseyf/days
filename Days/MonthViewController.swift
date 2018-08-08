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
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d, HH:mm"
            var date = startDate!
            print("SET DATE: \(formatter.string(from: date))")

            var flatList: [CalendarDayModel?] = []

            let month = Calendar.current.component(.month, from: date)
            var currentMonth = month
            while currentMonth == month {
                let weekday = Calendar.current.component(.weekday, from: date)
                print("weekday:\(weekday) - \(formatter.string(from: date))")
                let dayOfMonth = Calendar.current.component(.day, from: date)
                let dayModel = CalendarDayModel(date: date, weekday: weekday, dayOfMonth: dayOfMonth)
                flatList.append(dayModel)

                var components = Calendar.current.dateComponents(in: .current, from: date)
                components.day = components.day! + 1
                date = components.date!

                currentMonth = Calendar.current.component(.month, from: date)
            }

            var row: [CalendarDayModel?] = []

            let firstDayModel = flatList.first!!
            let lastDayModel = flatList.last!!
            for i in 1...7 {
                if i < firstDayModel.weekday {
                    row.append(nil)
                }
            }

            var matrix: [[CalendarDayModel?]] = []

            for (_, dayModel) in flatList.enumerated() {
                row.append(dayModel)
                if dayModel?.weekday == 7 {
                    matrix.append(row)
                    row = []
                }
            }

            if row.count > 0 { // incomplete row
                for i in 1...7 {
                    if i > lastDayModel.weekday {
                        row.append(nil)
                    }
                }
                matrix.append(row)
            }

            let monthModel = CalendarMonthModel(matrix: matrix, startDate: startDate!)
            print(monthModel)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cellWidth = floor(view.frame.width / 7)
        for i in 0..<7 {
            let cell = CalendarDayView()
            let origin = CGPoint(x: CGFloat(i) * cellWidth, y: 0)
            let size = CGSize(width: cellWidth, height: cellWidth)
            cell.frame = CGRect(origin: origin, size: size)
            view.addSubview(cell)
        }
    }
}
