//
//  CalendarMonthModel.swift
//  Days
//
//  Created by Anar Seyf on 8/9/18.
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
                let description = (day?.description ?? "--      ")
                let markers = "[" + (day?.isToday ?? false ? "T" : " ") + (day?.isSelected ?? false ? "*" : " ") + "]"
                let separator = (index == row.count - 1 ? "" : ", ")
                result += "\(description)\(markers)\(separator)"
            }
            result += "\n"
        }
        return result
    }

    static func build(forStartDate startDate: Date, selectedDate: Date?) -> CalendarMonthModel {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, HH:mm"

        let today = Utils.dateFloor(from: Date())!

        var date = startDate
        var flatList: [CalendarDayModel?] = []

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        var currentMonth = month
        while currentMonth == month {
            let weekday = calendar.component(.weekday, from: date)
            let dayOfMonth = calendar.component(.day, from: date)
            let isToday = (date == today)
            let isSelected = (date == selectedDate)
            let dayModel = CalendarDayModel(date: date,
                                            weekday: weekday,
                                            dayOfMonth: dayOfMonth,
                                            isToday: isToday,
                                            isSelected: isSelected)
            flatList.append(dayModel)

            var components = calendar.dateComponents(in: .current, from: date)
            components.day = components.day! + 1
            date = components.date!

            currentMonth = calendar.component(.month, from: date)
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

        return CalendarMonthModel(matrix: matrix, startDate: startDate)
    }
}
