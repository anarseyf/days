//
//  Utils.swift
//  Days
//
//  Created by Anar Seyf on 7/2/18.
//  Copyright © 2018 WY6CAT. All rights reserved.
//

import UIKit

class Utils {

    private static let defaultNotificationHour = 7
    private static let defaultNotificationMinute = 0

    static let secondsPerDay = 60 * 60 * 24
    static let minDays = 1
    static let maxDays = 366

    static let shared = Utils()

    let dateOnlyFormatter = DateFormatter()
    let dateNoYearFormatter = DateFormatter()
    let timeOnlyFormatter = DateFormatter()
    let dateTimeFormatter = DateFormatter()
    let intervalFormatter = DateComponentsFormatter()

    private init() {
        
        dateOnlyFormatter.dateStyle = .medium // Aug 5
        dateOnlyFormatter.timeStyle = .none
        dateNoYearFormatter.dateFormat = "MMM d" // see http://nsdateformatter.com
        timeOnlyFormatter.dateStyle = .none
        timeOnlyFormatter.timeStyle = .medium
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .medium

        intervalFormatter.allowedUnits = [.day, .hour, .minute]
        intervalFormatter.zeroFormattingBehavior = [.dropLeading, .pad]
        intervalFormatter.unitsStyle = .abbreviated
    }

    static func daysString(from days: Int, withNumber: Bool = true) -> String {
        let daysString = (days == 1 ? "day" : "days")
        return withNumber ? "\(days) \(daysString)" : daysString
    }

    static func notificationDate(fromTarget targetDate: Date, withTimeOverride overrideDate: Date? = nil) -> Date {

        var targetComponents = Utils.componentsFromDate(targetDate)
        targetComponents.day = targetComponents.day! - 1
        targetComponents.second = 0

        if (overrideDate == nil) {
            targetComponents.hour = defaultNotificationHour
            targetComponents.minute = defaultNotificationMinute
        }
        else {
            let overrideComponents = Utils.componentsFromDate(overrideDate!)
            targetComponents.hour = overrideComponents.hour
            targetComponents.minute = overrideComponents.minute

        }
        return targetComponents.date ?? targetDate
    }

    static func calendarModel(forStartDate startDate: Date) -> CalendarMonthModel {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, HH:mm"

        var date = startDate
        var flatList: [CalendarDayModel?] = []

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        var currentMonth = month
        while currentMonth == month {
            let weekday = calendar.component(.weekday, from: date)
            let dayOfMonth = calendar.component(.day, from: date)
            let dayModel = CalendarDayModel(date: date,
                                            weekday: weekday,
                                            dayOfMonth: dayOfMonth)
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

    static func componentsFromDate(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents(in: .current, from: date)
    }

    static func dateFloor(from date: Date?) -> Date? {

        guard let date = date else { return nil }

        var components = componentsFromDate(date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return components.date
    }
}
